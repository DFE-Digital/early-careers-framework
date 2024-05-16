# frozen_string_literal: true

RSpec.shared_examples "can change cohort and continue training" do |declaration_type, completed_training_at_attribute|
  describe "#can_change_cohort_and_continue_training?" do
    let(:declaration) { create(declaration_type, :paid, declaration_type: :started) }
    let(:participant_profile) { declaration.participant_profile }
    let(:current_cohort) { participant_profile.schedule.cohort }
    let(:cohort_start_year) { current_cohort.start_year + 3 }

    subject { participant_profile }

    it { is_expected.to be_can_change_cohort_and_continue_training(cohort_start_year:) }

    context "when the cohort is not 3 years after the participant's current cohort" do
      let(:cohort_start_year) { current_cohort.start_year - 3 }

      it { is_expected.not_to be_can_change_cohort_and_continue_training(cohort_start_year:) }
    end

    %i[paid payable eligible].each do |billable_declaration_type|
      context "when the participant has a completed, #{billable_declaration_type} declaration" do
        before do
          completed_milestone = participant_profile.schedule.milestones.find_by(declaration_type: :completed)
          completed_milestone.update!(start_date: 1.month.ago)

          create(declaration_type,
                 billable_declaration_type,
                 declaration_type: :completed,
                 declaration_date: completed_milestone.start_date + 1.day,
                 participant_profile:,
                 cpd_lead_provider: participant_profile.lead_provider.cpd_lead_provider)
        end

        it { is_expected.not_to be_can_change_cohort_and_continue_training(cohort_start_year:) }
      end
    end

    context "when the participant does not have billable, not completed declarations" do
      before { participant_profile.participant_declarations.billable.not_completed.destroy_all }

      it { is_expected.not_to be_can_change_cohort_and_continue_training(cohort_start_year:) }
    end

    context "when the participant has a #{completed_training_at_attribute}" do
      before { participant_profile.update("#{completed_training_at_attribute}": 1.month.ago) }

      it { is_expected.not_to be_can_change_cohort_and_continue_training(cohort_start_year:) }
    end
  end
end
