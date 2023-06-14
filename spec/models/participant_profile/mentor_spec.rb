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
end
