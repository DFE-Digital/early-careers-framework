# frozen_string_literal: true

RSpec.describe Schools::Participants::Status, type: :component, with_feature_flags: { eligibility_notifications: "active" } do
  let(:component) { described_class.new(participant_profile: profile) }

  context "when an email has been sent but the participant has not validated" do
    let(:profile) { create(:ect_participant_profile, :email_sent) }

    subject! { render_inline(component) }

    it "displays the details required content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.details_required.header"
      I18n.t("schools.participants.status.details_required.content").each do |content|
        expect(rendered_content).to have_content content
      end
    end
  end

  context "when an email bounced" do
    let(:profile) { create(:ect_participant_profile, :email_bounced) }

    subject! { render_inline(component) }

    it "displays the request for details failed content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.request_for_details_failed.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.request_for_details_failed.content"
    end
  end

  context "when no email has been sent" do
    let(:profile) { create(:ect_participant_profile) }

    subject! { render_inline(component) }

    it "displays the request to be sent content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.request_to_be_sent.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.request_to_be_sent.content"
    end
  end

  context "when the participant is doing FIP" do
    let(:school_cohort) { create(:school_cohort, :fip) }

    context "when the participant is an ECT" do
      let(:profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile: profile) }

        it "displays the eligible fip no partner content" do
          render_inline(component)
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip_no_partner.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip_no_partner.content"
        end

        context "when the school is in a partnership" do
          before { allow(component).to receive(:profile_status).and_return(:eligible_fip) }

          subject! { render_inline(component) }

          it "displays the eligible fip content" do
            expect(rendered_content).to have_content(I18n.t("schools.participants.status.eligible_fip.header"))
            expect(rendered_content).to have_content(I18n.t("schools.participants.status.eligible_fip.content"))
          end
        end
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the fip ect no qts content" do
          expect(rendered_content).to have_content(I18n.t("schools.participants.status.fip_ect_no_qts.header"))
          expect(rendered_content).to have_content(I18n.t("schools.participants.status.fip_ect_no_qts.content").first)
        end
      end

      context "when the participant has a previous induction" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the ineligible previous induction content" do
          expect(rendered_content).to have_content(I18n.t("schools.participants.status.ineligible_previous_induction.header"))
          expect(rendered_content).to have_content(I18n.t("schools.participants.status.ineligible_previous_induction.content"))
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the checking eligibility content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.content"
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the checking eligibility content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.content"
        end
      end
    end

    context "when the participant is a mentor" do
      let(:profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile: profile) }

        it "displays the eligible fip no partner content" do
          render_inline(component)
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip_no_partner.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip_no_partner.content"
        end

        context "when the school is in a partnership" do
          let!(:partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort) }
          before { allow(component).to receive(:profile_status).and_return(:eligible_fip) }

          subject! { render_inline(component) }

          it "displays the eligible fip content" do
            expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip.header"
            expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip.content"
          end
        end
      end

      context "when the participant has a previous participation (ERO)" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the ero mentor content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.ero_mentor.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.ero_mentor.content"
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the checking eligibility content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.content"
        end
      end

      context "when the participant is a duplicate profile" do
        let(:profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort:) }
        let!(:eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile: profile) }

        before do
          profile.reload
        end

        it "displays the eligible fip no partner content" do
          render_inline(component)
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip_no_partner.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip_no_partner.content"
        end

        context "when the school is in a partnership" do
          let!(:partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort) }
          before { allow(component).to receive(:profile_status).and_return(:eligible_fip) }

          subject! { render_inline(component) }

          it "displays the eligible fip content" do
            expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip.header"
            expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_fip.content"
          end
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the checking eligibility content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.checking_eligibility.content"
        end
      end
    end
  end

  context "when the participant is doing CIP" do
    let(:school_cohort) { create(:school_cohort, :cip) }
    context "when the participant is an ECT" do
      let(:profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has a previous induction" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end
    end

    context "when the participant is a mentor" do
      let(:profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }

      subject! { render_inline(component) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile: profile) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has a previous participation (ERO)" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile: profile) }

        subject! { render_inline(component) }

        it "displays the eligible cip content" do
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.header"
          expect(rendered_content).to have_content I18n.t "schools.participants.status.eligible_cip.content"
        end
      end
    end
  end
end
