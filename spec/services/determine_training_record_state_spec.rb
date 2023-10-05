# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineTrainingRecordState do
  describe "#call" do
    let(:induction_record1) { create(:induction_record) }
    let(:induction_record2) { create(:induction_record) }
    let(:participant_profile1) { induction_record1.participant_profile }
    let(:participant_profile2) { induction_record2.participant_profile }
    let(:induction_records) { [induction_record1, induction_record2] }

    subject(:record_states) { described_class.call(induction_records:) }

    it "returns the training record states indexed by participant profile id" do
      expect(record_states[participant_profile1.id]).to be_an_instance_of(TrainingRecordState)
      expect(record_states[participant_profile1.id]).to have_attributes({
        participant_profile: participant_profile1,
        induction_record: induction_record1,
      })

      expect(record_states[participant_profile2.id]).to be_an_instance_of(TrainingRecordState)
      expect(record_states[participant_profile2.id]).to have_attributes({
        participant_profile: participant_profile2,
        induction_record: induction_record2,
      })
    end

    context "when given a single induction record" do
      subject { described_class.call(induction_records: induction_record1) }

      it "returns the training record state indexed by participant profile id" do
        expect(record_states[participant_profile1.id]).to be_an_instance_of(TrainingRecordState)
        expect(record_states[participant_profile1.id]).to have_attributes({
          participant_profile: participant_profile1,
          induction_record: induction_record1,
        })
      end
    end
  end
end
