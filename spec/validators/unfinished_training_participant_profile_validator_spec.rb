# frozen_string_literal: true

require "rails_helper"

class UnfinishedTrainingParticipantProfileValidatorConsumerClass
  include ActiveModel::Model
  attr_accessor :participant_profile

  validates :participant_profile, unfinished_training_participant_profile: true
end

RSpec.describe UnfinishedTrainingParticipantProfileValidator, type: :model do
  subject { UnfinishedTrainingParticipantProfileValidatorConsumerClass.new(participant_profile:) }

  context "when the participant is not a ParticipantProfile instance" do
    let(:participant_profile) { nil }

    it "is not valid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:participant_profile]).to include(I18n.t("errors.participant_profile.not_a_participant_profile"))
    end
  end

  context "when the participant has not completed training" do
    let(:participant_profile) { ParticipantProfile::ECT.new(induction_completion_date: nil) }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when the participant has completed training" do
    let(:participant_profile) { ParticipantProfile::Mentor.new(mentor_completion_date: Date.current) }

    it "is not valid" do
      expect(subject).to_not be_valid
      expect(subject.errors[:participant_profile]).to include(I18n.t("errors.participant_profile.training_complete"))
    end
  end
end
