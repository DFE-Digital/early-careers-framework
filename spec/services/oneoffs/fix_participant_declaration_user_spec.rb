# frozen_string_literal: true

RSpec.describe Oneoffs::FixParticipantDeclarationUser do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:declaration1) { create(:ect_participant_declaration, cpd_lead_provider:) }
  let(:user1) { declaration1.user }
  let(:declaration2) { create(:ect_participant_declaration, cpd_lead_provider:) }
  let(:user2) { declaration2.user }

  subject { described_class.new }

  before do
    teacher_profile = TeacherProfile.find_or_create_by!(user: user2)
    user1.participant_identities.each do |identity|
      identity.update!(user: user2)
      identity.participant_profiles.each do |participant_profile|
        participant_profile.update!(teacher_profile:)
      end
    end
    user1.reload
    user2.reload
    declaration1.reload
    declaration2.reload
  end

  describe "#call" do
    it "fixes the user mismatch on declaration" do
      expect(declaration1.user).to eql(user1)
      expect(declaration2.user).to eql(user2)
      subject.call
      expect(declaration1.reload.user).to eql(user2)
      expect(declaration2.reload.user).to eql(user2)
    end
  end

  describe "#incorrect_participant_declarations" do
    it "returns declarations" do
      expect(subject.incorrect_participant_declarations.to_a).to eql([declaration1])
    end
  end
end
