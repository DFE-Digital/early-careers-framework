# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantIdentityPresenceValidator, :with_default_schedules do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      validates :participant_id, participant_identity_presence: true

      attr_reader :participant_identity

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def initialize(participant_identity:)
        @participant_identity = participant_identity
      end
    end
  end

  describe "#validate" do
    subject { klass.new(participant_identity:) }

    let(:profile) { create(:npq_participant_profile) }
    let(:user) { profile.user }
    let(:participant_identity) { profile.participant_identity }

    context "with participant identity" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with no participant identity" do
      let(:participant_identity) { nil }

      it "is invalid" do
        expect(subject).to be_invalid
      end

      it "has a meaningful error", :aggregate_failures do
        expect(subject).to be_invalid
        expect(subject.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
      end
    end
  end
end
