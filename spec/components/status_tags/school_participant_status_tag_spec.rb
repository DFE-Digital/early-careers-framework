# frozen_string_literal: true

RSpec.describe StatusTags::SchoolParticipantStatusTag, type: :component, with_feature_flags: { eligibility_notifications: "active" } do
  let(:component) { described_class.new participant_profile: }

  subject { render_inline(component) }

  context "when an email has been sent but the participant has not validated" do
    let(:participant_profile) { create(:ect_participant_profile, :email_sent) }

    it "displays the details required content" do
      expect(subject).to have_content I18n.t "status_tags.school_participant_status.details_required.label"

      I18n.t("status_tags.school_participant_status.details_required.description").each do |content|
        expect(subject).to have_content content
      end
    end
  end

  context "when an email bounced" do
    let(:participant_profile) { create(:ect_participant_profile, :email_bounced) }

    it "displays the request for details failed content" do
      expect(subject).to have_content I18n.t "status_tags.school_participant_status.request_for_details_failed.label"
      expect(subject).to have_content I18n.t "status_tags.school_participant_status.request_for_details_failed.description"
    end
  end

  context "when no email has been sent" do
    let(:participant_profile) { create(:ect_participant_profile) }

    it "displays the request to be sent content" do
      expect(subject).to have_content I18n.t "status_tags.school_participant_status.request_to_be_sent.label"
      expect(subject).to have_content I18n.t "status_tags.school_participant_status.request_to_be_sent.description"
    end
  end

  context "when the participant is doing FIP" do
    let(:school_cohort) { create(:school_cohort, :fip) }

    context "when the participant is an ECT" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it "displays the eligible fip no partner content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip_no_partner.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip_no_partner.description"
        end

        context "when the school is in a partnership" do
          before { allow(component).to receive(:record_state).and_return(:eligible_fip) }

          it "displays the eligible fip content" do
            expect(subject).to have_content(I18n.t("status_tags.school_participant_status.eligible_fip.label"))
            expect(subject).to have_content(I18n.t("status_tags.school_participant_status.eligible_fip.description"))
          end
        end
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

        it "displays the fip ect no qts content" do
          expect(subject).to have_content(I18n.t("status_tags.school_participant_status.fip_ect_no_qts.label"))
          expect(subject).to have_content(I18n.t("status_tags.school_participant_status.fip_ect_no_qts.description").first)
        end
      end

      context "when the participant has a previous induction" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

        it "displays the ineligible previous induction content" do
          expect(subject).to have_content(I18n.t("status_tags.school_participant_status.ineligible_previous_induction.label"))
          expect(subject).to have_content(I18n.t("status_tags.school_participant_status.ineligible_previous_induction.description"))
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it "displays the checking eligibility content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.description"
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it "displays the checking eligibility content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.description"
        end
      end
    end

    context "when the participant is a mentor" do
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it "displays the eligible fip no partner content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip_no_partner.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip_no_partner.description"
        end

        context "when the school is in a partnership" do
          let!(:partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort) }

          before { allow(component).to receive(:record_state).and_return(:eligible_fip) }

          it "displays the eligible fip content" do
            expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip.label"
            expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip.description"
          end
        end
      end

      context "when the participant has a previous participation (ERO)" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

        it "displays the ero mentor content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.ero_mentor.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.ero_mentor.description"
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it "displays the checking eligibility content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.description"
        end
      end

      context "when the participant is a duplicate profile" do
        let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort:) }
        let!(:eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile:) }

        before { participant_profile.reload }

        it "displays the eligible fip no partner content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip_no_partner.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip_no_partner.description"
        end

        context "when the school is in a partnership" do
          let!(:partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort) }

          before { allow(component).to receive(:record_state).and_return(:eligible_fip) }

          it "displays the eligible fip content" do
            expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip.label"
            expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_fip.description"
          end
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it "displays the checking eligibility content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.checking_eligibility.description"
        end
      end
    end
  end

  context "when the participant is doing CIP" do
    let(:school_cohort) { create(:school_cohort, :cip) }

    context "when the participant is an ECT" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has a previous induction" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end
    end

    context "when the participant is a mentor" do
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has a previous participation (ERO)" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it "displays the eligible cip content" do
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.label"
          expect(subject).to have_content I18n.t "status_tags.school_participant_status.eligible_cip.description"
        end
      end
    end
  end
end
