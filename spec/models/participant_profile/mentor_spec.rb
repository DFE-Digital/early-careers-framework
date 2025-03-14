# frozen_string_literal: true

require "rails_helper"

describe ParticipantProfile::Mentor, type: :model do
  let(:eligible_cohort) { create(:cohort, :current, :payments_frozen) }
  let(:ineligible_cohort) { eligible_cohort.next }

  let(:instance) { described_class.new }

  describe "associations" do
    it { is_expected.to have_many(:mentee_profiles).class_name("ParticipantProfile::ECT").with_foreign_key(:mentor_profile_id).dependent(:nullify) }
    it { is_expected.to have_many(:mentees).through(:mentee_profiles).source(:user) }
    it { is_expected.to have_many(:school_mentors).dependent(:destroy).with_foreign_key(:participant_profile_id) }
    it { is_expected.to have_many(:schools).through(:school_mentors) }
    it { is_expected.to have_many(:participant_declarations).class_name("ParticipantDeclaration::Mentor").with_foreign_key(:participant_profile_id) }
  end

  describe "#mentor" do
    it { expect(instance).to be_mentor }
  end

  describe "#role" do
    it { expect(instance.role).to eq("Mentor") }
  end

  describe "#participant_type" do
    it { expect(instance.participant_type).to eq(:mentor) }
  end

  describe "#complete_training!" do
    subject(:mentor_profile) { create(:seed_mentor_participant_profile, :valid) }
    let(:completion_date) { 1.week.ago.to_date }
    let(:completion_reason) { described_class.mentor_completion_reasons.values.sample }

    before do
      mentor_profile.complete_training!(completion_date:, completion_reason:)
    end

    it "sets the mentor completion date" do
      expect(mentor_profile.mentor_completion_date).to eq(completion_date)
    end

    it "sets the mentor completion reason" do
      expect(mentor_profile.mentor_completion_reason).to eq(completion_reason)
    end
  end

  describe "#completed_training?" do
    context "when a completion date is present" do
      before do
        instance.mentor_completion_date = 1.week.ago.to_date
      end

      it "returns true" do
        expect(instance).to be_completed_training
      end
    end

    context "when a completion date is not present" do
      it "returns false" do
        expect(instance).not_to be_completed_training
      end
    end
  end

  include_context "can change cohort and continue training", :mentor, :ect, :mentor_completion_date

  def build_profile(attrs = {})
    create(:mentor_participant_profile, attrs).tap do |participant_profile|
      create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :fip))
    end
  end

  def build_declaration(attrs = {})
    create(:mentor_participant_declaration, attrs) do |declaration|
      participant_profile = declaration.participant_profile
      create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :fip))
    end
  end

  describe ".archivable_from_frozen_cohort" do
    let(:restrict_to_participant_ids) { [] }
    let!(:eligible_no_declarations) { build_profile(cohort: eligible_cohort) }
    let!(:eligible_only_unbillable_declarations) { build_declaration(state: :voided, cohort: eligible_cohort).participant_profile }
    let!(:eligible_with_cip) do
      # Participant with CIP induction record.
      build_profile(cohort: eligible_cohort).tap do |participant_profile|
        create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :cip))
      end
    end

    before do
      # Participant not in an eligible cohort.
      build_profile(cohort: ineligible_cohort)

      # Participant with billable declarations.
      build_declaration(state: :paid, cohort: eligible_cohort)

      # Other participant type.
      create(:ect_participant_profile, cohort: eligible_cohort)

      # Ineligible due to having the mentor_completion_date populated.
      build_declaration(state: :ineligible, cohort: eligible_cohort).participant_profile.update!(mentor_completion_date: 1.month.ago)
    end

    subject { described_class.archivable_from_frozen_cohort(restrict_to_participant_ids:) }

    it { is_expected.to contain_exactly(eligible_no_declarations, eligible_only_unbillable_declarations, eligible_with_cip) }

    it "does not include participants that have mentees" do
      build_profile(cohort: eligible_cohort).tap do |mentor_profile|
        create(:induction_record, :ect, mentor_profile:)
      end

      is_expected.to contain_exactly(eligible_no_declarations, eligible_only_unbillable_declarations, eligible_with_cip)
    end

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

    ParticipantDeclaration.non_archivable_states.each do |declaration_state|
      it "returns false if the participant has #{declaration_state} declarations" do
        paid_declaration = build_declaration(state: declaration_state, cohort: eligible_cohort)
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
    end

    it "returns true if the participant has a CIP induction record" do
      participant_profile = build_profile(cohort: eligible_cohort)
      create(:induction_record, participant_profile:, induction_programme: create(:induction_programme, :cip))
      expect(participant_profile).to be_archivable_from_frozen_cohort
    end
  end
end
