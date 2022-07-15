# frozen_string_literal: true

RSpec.describe Participants::Mentor do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include Participants::Mentor

      attr_accessor :participant_identity
    end
  end

  subject { klass.new(participant_identity:) }

  describe "validation" do
    context "when single profile is withdrawn" do
      let(:participant_identity) { participant_profile.participant_identity }
      let(:participant_profile) { create(:mentor_participant_profile, :withdrawn) }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("Cannot perform actions on a withdrawn participant")
      end
    end

    context "when 2 profiles: 1 active, 1 withdrawn" do
      let(:participant_identity) { participant_profile.participant_identity }
      let(:participant_profile) { create(:mentor_participant_profile) }

      before do
        create(:mentor_participant_profile, :withdrawn, participant_identity:)
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
