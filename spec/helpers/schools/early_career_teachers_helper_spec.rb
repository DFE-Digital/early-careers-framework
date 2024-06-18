# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::EarlyCareerTeachersHelper, type: :helper do
  describe "#completed_participants" do
    let(:participant_1) { double("ParticipantProfile", induction_completion_date: 3.days.ago) }
    let(:participant_2) { double("ParticipantProfile", induction_completion_date: nil) }
    let(:participant_3) { double("ParticipantProfile", induction_completion_date: 1.day.ago) }

    context "when all participants are completed" do
      let(:participants) { [participant_1, participant_3] }

      it "returns a sorted list of participants in reverse chronological order" do
        expect(helper.completed_participants(participants)).to eq([participant_3, participant_1])
      end
    end

    context "when some participants are not completed" do
      let(:participants) { [participant_1, participant_2, participant_3] }

      it "returns a sorted list of participants in reverse chronological order with incompletes at the end" do
        expect(helper.completed_participants(participants)).to eq([participant_3, participant_1, participant_2])
      end
    end
  end
end
