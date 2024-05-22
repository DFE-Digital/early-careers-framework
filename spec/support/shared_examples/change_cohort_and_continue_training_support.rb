# frozen_string_literal: true

RSpec.shared_examples "can change cohort and continue training" do |participant_type, other_participant_type, completed_training_at_attribute|
  let(:declaration_type) { "#{participant_type}_participant_declaration" }

  describe ".eligible_to_change_cohort_and_continue_training" do
    let(:current_cohort) { eligible_participant.schedule.cohort }
    let(:restrict_to_participant_ids) { [] }
    let(:cpd_lead_provider) { eligible_participant.lead_provider.cpd_lead_provider }
    let(:eligible_participants) { create_list(declaration_type, 3, :payable, declaration_type: :started).map(&:participant_profile) }
    let(:eligible_participant) { eligible_participants.first }
    let(:in_cohort_start_year) { current_cohort.start_year + ParticipantProfile::ECF::CHANGE_COHORT_AND_CONTINUE_TRAINING_DELTA }

    before do
      current_cohort.update!(payments_frozen_at: Time.zone.now)

      # Extra declaration on the same participant to ensure the results are distinct.
      create(declaration_type, :payable, declaration_type: :"retained-1", participant_profile: eligible_participant, cpd_lead_provider:)

      # Ineligible due to being a declaration for another participant type.
      create("#{other_participant_type}_participant_declaration", :payable, declaration_type: :started)

      # Ineligible due to having a billable, completed declaration.
      create(declaration_type, :paid).tap { |d| d.update!(declaration_type: :completed) }

      # Ineligible due to having the completed_training_at_attribute populated.
      create(declaration_type, :paid, declaration_type: :started).participant_profile.update!("#{completed_training_at_attribute}": 1.month.ago)

      # Ineligible due to not being in a payments frozen cohort.
      create(declaration_type, :payable, declaration_type: :started).tap do |declaration|
        schedule = create(:ecf_schedule, cohort: current_cohort.next)
        declaration.participant_profile.update!(schedule:)
      end
    end

    subject { described_class.eligible_to_change_cohort_and_continue_training(in_cohort_start_year:, restrict_to_participant_ids:) }

    it { is_expected.to contain_exactly(*eligible_participants) }

    context "when restricted to a set of participant IDs" do
      let(:restrict_to_participant_ids) { [eligible_participants.first.id] }

      it { is_expected.to contain_exactly(eligible_participants.first) }
    end
  end

  describe "#eligible_to_change_cohort_and_continue_training?" do
    let(:declaration) { create(declaration_type, :paid, declaration_type: :started) }
    let(:participant_profile) { declaration.participant_profile }
    let(:current_cohort) { participant_profile.schedule.cohort }
    let(:in_cohort_start_year) { current_cohort.start_year + ParticipantProfile::ECF::CHANGE_COHORT_AND_CONTINUE_TRAINING_DELTA }

    before { current_cohort.update!(payments_frozen_at: Time.zone.now) }

    subject { participant_profile }

    it { is_expected.to be_eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }

    context "when the participant is not in a payments frozen cohort" do
      before { current_cohort.update!(payments_frozen_at: nil) }

      it { is_expected.not_to be_eligible_to_change_cohort_and_continue_training(in_cohort_start_year:) }
    end

    context "when the participant is not in the correct payments frozen cohort" do
      before do
        schedule = create(:ecf_schedule, cohort: current_cohort.next)
        current_cohort.next.update!(payments_frozen_at: Time.zone.now)
        participant_profile.update!(schedule:)
      end

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

  describe "#eligible_to_change_cohort_back_to_their_payments_frozen_original?" do
    let(:declaration) { create(declaration_type, :paid, declaration_type: :started) }
    let(:participant_profile) { declaration.participant_profile }
    let(:current_cohort) { participant_profile.schedule.cohort }
    let(:previous_cohort) { create(:cohort, payments_frozen_at: 1.week.ago, start_year: to_cohort_start_year) }
    let(:to_cohort_start_year) { current_cohort.start_year - ParticipantProfile::ECF::CHANGE_COHORT_AND_CONTINUE_TRAINING_DELTA }

    before do
      declaration.update!(cohort: previous_cohort)
      participant_profile.update!(cohort_changed_after_payments_frozen: true)
      previous_cohort.update!(payments_frozen_at: Time.zone.now)
    end

    subject { participant_profile }

    it { is_expected.to be_eligible_to_change_cohort_back_to_their_payments_frozen_original(to_cohort_start_year:) }

    context "when the to_cohort_start_year is not 3 years before the current cohort" do
      let(:to_cohort_start_year) { current_cohort.start_year - 1 }

      it { is_expected.not_to be_eligible_to_change_cohort_back_to_their_payments_frozen_original(to_cohort_start_year:) }
    end

    context "when the previous cohort is not payments frozen" do
      before { previous_cohort.update!(payments_frozen_at: nil) }

      it { is_expected.not_to be_eligible_to_change_cohort_back_to_their_payments_frozen_original(to_cohort_start_year:) }
    end

    context "when the participant is not cohort_changed_after_payments_frozen" do
      before { participant_profile.update!(cohort_changed_after_payments_frozen: false) }

      it { is_expected.not_to be_eligible_to_change_cohort_back_to_their_payments_frozen_original(to_cohort_start_year:) }
    end

    %i[paid payable eligible submitted].each do |billable_or_changeable_declaration_type|
      context "when the participant has a #{billable_or_changeable_declaration_type} declaration for the current cohort" do
        before { create(declaration_type, :payable, declaration_type: "retained-1", participant_profile:, cpd_lead_provider: participant_profile.lead_provider.cpd_lead_provider) }

        it { is_expected.not_to be_eligible_to_change_cohort_back_to_their_payments_frozen_original(to_cohort_start_year:) }
      end
    end
  end
end
