# frozen_string_literal: true

RSpec.describe Schools::Participants::Status, type: :component, with_feature_flags: { eligibility_notifications: "active" } do
  let(:induction_record) { create(:induction_record, participant_profile:) }
  let(:component) { described_class.new(induction_record:) }

  context "when the participant has been withdrawn from induction" do
    let(:participant_profile) { create(:ect_participant_profile, :withdrawn_record) }

    subject! { render_inline(component) }

    it "displays the contacted for information content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_longer_being_trained_sit.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_longer_being_trained_sit.content"
    end
  end

  context "when the participant has been withdrawn from training" do
    let(:participant_profile) { create(:ect_participant_profile, training_status: :withdrawn) }

    subject! { render_inline(component) }

    it "displays the contacted for information content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_longer_being_trained_provider.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_longer_being_trained_provider.content"
    end
  end

  context "when an email bounced" do
    let(:participant_profile) { create(:ect_participant_profile, :email_bounced) }

    subject! { render_inline(component) }

    it "displays the check email address content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.check_email_address.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.check_email_address.content"
    end
  end

  context "when an email has been sent but the participant has not validated" do
    let(:participant_profile) { create(:ect_participant_profile, :email_sent) }

    subject! { render_inline(component) }

    it "displays the contacted for information content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.contacted_for_info.header"
      I18n.t("schools.participants.status.contacted_for_info.content").each do |content|
        expect(rendered_content).to have_content content
      end
    end
  end

  context "when no trn has been provided" do
    let(:teacher_profile) { create(:teacher_profile, trn: nil) }
    let(:participant_profile) { create(:ect_participant_profile, teacher_profile:) }

    subject! { render_inline(component) }

    it "displays the no trn provided content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_trn_provided.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_trn_provided.content"
    end
  end

  context "when the participant has active flags and manual check status" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

    subject! { render_inline(component) }

    it "displays the pending content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.pending.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.pending.content"
    end
  end

  context "when the participant has a TRN mismatch" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

    subject! { render_inline(component) }

    it "displays the checking eligibility content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.pending.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.pending.content"
    end
  end

  context "when the participant has no QTS" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

    subject! { render_inline(component) }

    it "displays the fip ect no qts content" do
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.waiting_for_qts.header"))
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.waiting_for_qts.content").first)
    end
  end

  context "when the participant has no induction" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :no_induction_state, participant_profile:) }

    subject! { render_inline(component) }

    it "displays the no induction content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_induction_start_date.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.no_induction_start_date.content"
    end
  end

  context "when the participant has a previous induction" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

    subject! { render_inline(component) }

    it "displays the statutory induction completed content" do
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.statutory_induction_completed.header"))
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.statutory_induction_completed.content"))
    end
  end

  context "when the participant has a previous participation (ERO)" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

    subject! { render_inline(component) }

    it "displays the statutory induction completed content" do
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.statutory_induction_completed.header"))
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.statutory_induction_completed.content"))
    end
  end

  context "when the participant is exempt from ECF" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :exempt_from_induction_state, participant_profile:) }

    subject! { render_inline(component) }

    it "displays the exempt content" do
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.exempt.header"))
      expect(rendered_content).to have_content(I18n.t("schools.participants.status.exempt.content"))
    end
  end

  context "when the participant is a duplicate profile" do
    let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile:) }

    before do
      participant_profile.reload
    end

    it "displays the duplicate profile content" do
      render_inline(component)
      expect(rendered_content).to have_content I18n.t "schools.participants.status.duplicate_profile.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.duplicate_profile.content"
    end
  end

  context "when the participant failed induction" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, :ineligible, participant_profile:) }

    before do
      participant_profile.reload
    end

    it "displays the failed induction content" do
      render_inline(component)
      expect(rendered_content).to have_content I18n.t "schools.participants.status.failed_induction.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.failed_induction.content"
    end
  end

  context "when the participant is not qualified for ECF" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, :ineligible, participant_profile:) }

    before do
      participant_profile.reload
    end

    it "displays the not qualified content" do
      render_inline(component)
      expect(rendered_content).to have_content I18n.t "schools.participants.status.not_qualified.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.not_qualified.content"
    end
  end

  context "when the participant has deferred induction" do
    let(:participant_profile) { create(:ect_participant_profile, training_status: :deferred) }

    before do
      participant_profile.reload
    end

    it "displays the training deferred content" do
      render_inline(component)
      expect(rendered_content).to have_content I18n.t "schools.participants.status.training_deferred.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.training_deferred.content"
    end
  end

  context "when the participant has completed induction" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_record) { create(:induction_record, participant_profile:, induction_status: :completed) }

    before do
      participant_profile.reload
    end

    it "displays the training completed content" do
      render_inline(component)
      expect(rendered_content).to have_content I18n.t "schools.participants.status.training_completed.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.training_completed.content"
    end
  end

  context "when the participant is leaving their current school" do
    let(:end_date) { Date.current + 2.days }
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_record) { create(:induction_record, :leaving, participant_profile:, end_date:) }

    before do
      participant_profile.reload
    end

    it "displays the leaving school content" do
      render_inline(component)
      expect(rendered_content).to have_content I18n.t "schools.participants.status.leaving_your_school.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.leaving_your_school.content", end_date: end_date.to_s(:govuk)
    end
  end

  context "when the participant is joining a school" do
    let(:start_date) { Date.current + 2.days }
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_record) { create(:induction_record, :school_transfer, participant_profile:, start_date:) }

    before do
      participant_profile.reload
    end

    it "displays the joining school content" do
      render_inline(component)
      expect(rendered_content).to have_content I18n.t "schools.participants.status.joining_your_school.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.joining_your_school.content", start_date: start_date.to_s(:govuk)
    end
  end

  context "when the participant is not mentoring" do
    let(:participant_profile) { create(:mentor_participant_profile) }

    before do
      render_inline(component)
    end

    it "displays the not mentoring content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.not_mentoring.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.not_mentoring.content"
    end
  end

  context "when the participant is mentoring some ects" do
    let(:participant_profile) { create(:mentor_participant_profile) }
    let(:component) { described_class.new(induction_record:, has_mentees: true) }

    before do
      render_inline(component)
    end

    it "displays the mentoring content" do
      expect(rendered_content).to have_content I18n.t "schools.participants.status.mentoring.header"
      expect(rendered_content).to have_content I18n.t "schools.participants.status.mentoring.content"
    end
  end
end
