# frozen_string_literal: true

RSpec.shared_examples "can archive participant profile" do |other_participant_type, completed_training_at_attribute|
  let(:eligible_cohort) { create(:cohort, :current, :payments_frozen) }
  let(:ineligible_cohort) { eligible_cohort.next }

  def build_profile(attrs = {})
    create_profile(attrs).tap do |participant_profile|
      create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :fip))
    end
  end

  def build_declaration(attrs = {})
    create_declaration(attrs) do |declaration|
      participant_profile = declaration.participant_profile
      create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :fip))
    end
  end

  describe ".archivable_from_frozen_cohort" do
    let(:restrict_to_participant_ids) { [] }
    let(:eligible_no_declarations) { build_profile(cohort: eligible_cohort) }
    let(:eligible_only_unbillable_declarations) { build_declaration(state: :voided, cohort: eligible_cohort).participant_profile }

    before do
      # Participant not in an eligible cohort.
      build_profile(cohort: ineligible_cohort)

      # Participant with billable declarations.
      build_declaration(state: :paid, cohort: eligible_cohort)

      # Other participant type.
      create("#{other_participant_type}_participant_profile", cohort: eligible_cohort)

      # Ineligible due to having the completed_training_at_attribute populated.
      build_declaration(state: :ineligible, cohort: eligible_cohort).participant_profile.update!("#{completed_training_at_attribute}": 1.month.ago)

      # Participant with CIP induction record.
      build_profile(cohort: eligible_cohort).tap do |participant_profile|
        create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :cip))
      end
    end

    subject { described_class.archivable_from_frozen_cohort(restrict_to_participant_ids:) }

    it { is_expected.to contain_exactly(eligible_no_declarations, eligible_only_unbillable_declarations) }

    context "when restricted to a set of participant IDs" do
      let(:restrict_to_participant_ids) { [eligible_no_declarations.id] }

      it { is_expected.to contain_exactly(eligible_no_declarations) }
    end
  end

  describe "archivable_from_frozen_cohort?" do
    it "returns true if the participant is in an eligible cohort and has no declarations" do
      participant_profile = build_profile(cohort: eligible_cohort)
      expect(participant_profile).to be_archivable_from_frozen_cohort
    end

    %i[ineligible voided submitted].each do |unbillable_state|
      it "returns true if the participant is in an eligible cohort and the participant has only #{unbillable_state} declarations" do
        participant_profile = build_declaration(state: unbillable_state, cohort: eligible_cohort).participant_profile
        expect(participant_profile).to be_archivable_from_frozen_cohort
      end
    end

    it "returns false if the participant is not in an eligible cohort" do
      participant_profile = build_profile(cohort: ineligible_cohort)
      expect(participant_profile).not_to be_archivable_from_frozen_cohort
    end

    it "returns false if the participant has not archivable declarations" do
      paid_declaration = build_declaration(state: :paid, cohort: eligible_cohort)
      participant_profile = paid_declaration.participant_profile
      declaration_date = participant_profile.schedule.milestones.find_by(declaration_type: "retained-2").milestone_date - 1.day
      travel_to declaration_date do
        build_declaration(state: :voided,
                          cohort: eligible_cohort,
                          participant_profile:,
                          cpd_lead_provider: paid_declaration.cpd_lead_provider,
                          declaration_date:,
                          declaration_type: "retained-2")
        expect(participant_profile).not_to be_archivable_from_frozen_cohort
      end
    end

    it "returns false if the participant has a CIP induction record" do
      participant_profile = build_profile(cohort: eligible_cohort)
      create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :cip))
      expect(participant_profile).not_to be_archivable_from_frozen_cohort
    end
  end
end
