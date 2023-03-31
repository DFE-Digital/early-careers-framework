# frozen_string_literal: true

RSpec.describe StatusTags::AdminParticipantStatusTag, :with_training_record_state_examples, type: :component do
  let(:participant_profile) { create :seed_ect_participant_profile }

  let(:component) { described_class.new participant_profile: }

  subject(:label) { render_inline component }

  I18n.t("status_tags.admin_participant_status").each do |key, value|
    context "when :#{key} is the determined state" do
      before { allow(component).to receive(:record_state).and_return(key) }
      it { is_expected.to have_text value[:label] }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--#{value[:colour]}", exact_text: value[:label]) }
    end

    context "has a withdrawn status" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Withdrawn by provider") }

      context "when an active induction record is available" do
        let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
        let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

        let(:component) { described_class.new(participant_profile:, induction_record:) }

        it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start") }
      end
    end
  end
end
