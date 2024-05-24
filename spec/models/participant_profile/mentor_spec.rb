# frozen_string_literal: true

require "rails_helper"

describe ParticipantProfile::Mentor, type: :model do
  let(:instance) { described_class.new }

  describe "associations" do
    it { is_expected.to have_many(:mentee_profiles).class_name("ParticipantProfile::ECT").with_foreign_key(:mentor_profile_id).dependent(:nullify) }
    it { is_expected.to have_many(:mentees).through(:mentee_profiles).source(:user) }
    it { is_expected.to have_many(:school_mentors).dependent(:destroy).with_foreign_key(:participant_profile_id) }
    it { is_expected.to have_many(:schools).through(:school_mentors) }
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

  include_context "can archive participant profile", :ect, :mentor_completion_date do
    def create_declaration(attrs = {})
      create(:mentor_participant_declaration, attrs)
    end

    def create_profile(attrs = {})
      create(:mentor_participant_profile, attrs)
    end

    describe ".archivable" do
      subject { described_class.archivable(for_cohort_start_year:) }

      it "does not include participants that have mentees" do
        build_profile(cohort: eligible_cohort).tap do |mentor_profile|
          create(:induction_record, :ect, mentor_profile:)
        end

        eligible_participant = build_profile(cohort: eligible_cohort)

        is_expected.to contain_exactly(eligible_participant)
      end
    end
  end
end
