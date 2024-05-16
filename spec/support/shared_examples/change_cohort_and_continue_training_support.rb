# frozen_string_literal: true

RSpec.shared_examples "can change cohort and continue training" do |participant_type, other_participant_type, completed_training_at_attribute|
  let(:declaration_type) { "#{participant_type}_participant_declaration" }

  describe ".eligible_to_change_cohort_and_continue_training" do
    let(:current_cohort) { eligible_participant.schedule.cohort }
    let(:in_cohort_start_year) { current_cohort.start_year + 3 }
    let(:cpd_lead_provider) { eligible_participant.lead_provider.cpd_lead_provider }
    let(:eligible_participant) { create(declaration_type, :payable, declaration_type: :started).participant_profile }

    before do
      # Extra declaration on the same participant to ensure the results are distinct.
      create(declaration_type, :payable, declaration_type: :"retained-1", participant_profile: eligible_participant, cpd_lead_provider:)

      # Ineligible due to being a declaration for another participant type.
      create("#{other_participant_type}_participant_declaration", :payable, declaration_type: :started)

      # Ineligible due to having a billable, completed declaration.
      create(declaration_type, :paid).tap { |d| d.update!(declaration_type: :completed) }

      # Ineligible due to having the completed_training_at_attribute populated.
      create(declaration_type, :paid, declaration_type: :started).participant_profile.update!("#{completed_training_at_attribute}": 1.month.ago)

      # Ineligible due to not being in the applicable cohort.
      create(declaration_type, :payable, declaration_type: :started).tap do |declaration|
        schedule = create(:ecf_schedule, cohort: create(:cohort, start_year: in_cohort_start_year - 1))
        declaration.participant_profile.update!(schedule:)
      end
    end

    subject { described_class.eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }

    it { is_expected.to contain_exactly(eligible_participant) }
  end

  describe "#eligible_to_change_cohort_and_continue_training?" do
    let(:declaration) { create(declaration_type, :paid, declaration_type: :started) }
    let(:participant_profile) { declaration.participant_profile }
    let(:current_cohort) { participant_profile.schedule.cohort }
    let(:in_cohort_start_year) { current_cohort.start_year + 3 }

    subject { participant_profile }

    it { is_expected.to be_eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }

    context "when the cohort is not #{Cohort::OPEN_COHORTS_COUNT} years after the participant's current cohort" do
      let(:in_cohort_start_year) { current_cohort.start_year + Cohort::OPEN_COHORTS_COUNT + 1 }

      it { is_expected.not_to be_eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }
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

        it { is_expected.not_to be_eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }
      end
    end

    context "when the participant does not have billable, not completed declarations" do
      before { declaration.destroy }

      it { is_expected.not_to be_eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }
    end

    context "when the participant has a #{completed_training_at_attribute}" do
      before { participant_profile.update!("#{completed_training_at_attribute}": 1.month.ago) }

      it { is_expected.not_to be_eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }
    end
  end
end
