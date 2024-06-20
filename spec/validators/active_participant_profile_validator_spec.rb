# frozen_string_literal: true

require "rails_helper"

class ActiveParticipantProfileValidatorConsumerClass
  include ActiveModel::Model
  attr_accessor :participant_profile

  validates :participant_profile, active_participant_profile: true
end

RSpec.describe ActiveParticipantProfileValidator, type: :model do
  subject { ActiveParticipantProfileValidatorConsumerClass.new(participant_profile:) }

  context "when the participant is not a ParticipantProfile instance" do
    let(:participant_profile) { nil }

    it "is not valid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:participant_profile]).to include(I18n.t("errors.participant_profile.not_a_participant_profile"))
    end
  end

  context "when the participant has not active induction status" do
    let(:participant_profile) { ParticipantProfile::ECT.new(status: :withdrawn) }

    it "is not valid" do
      expect(subject).to_not be_valid
      expect(subject.errors[:participant_profile]).to include(I18n.t("errors.participant_profile.not_active"))
    end
  end

  context "when the participant has active induction status" do
    let(:participant_profile) { ParticipantProfile::Mentor.new(status: :active) }

    it "is valid" do
      expect(subject).to be_valid
      expect(subject.errors[:participant_profile]).to be_empty
    end
  end
end
