# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Participants::ChangeInductionStartDate do
  let(:participant_profile) { double(ParticipantProfile, update!: true) }
  let(:induction_start_date) { 3.weeks.from_now }

  subject { described_class.new(participant_profile, induction_start_date:) }

  describe "#initialize" do
    it "can be initialized with a participant profile and a date" do
      expect(subject).to be_a(described_class)

      expect(subject.participant_profile).to eql(participant_profile)
      expect(subject.induction_start_date).to eql(induction_start_date)
    end
  end

  describe "#call" do
    it "updates the participant profile's induction_start_date field with the supplied date when called" do
      subject.call

      expect(participant_profile).to have_received(:update!).with(induction_start_date:)
    end
  end
end
