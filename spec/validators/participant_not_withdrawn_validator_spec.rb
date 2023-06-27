# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantNotWithdrawnValidator do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      validates :participant_id, participant_not_withdrawn: true

      attr_reader :participant_profile, :cpd_lead_provider, :declaration_date

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def initialize(participant_profile:, cpd_lead_provider:, declaration_date:)
        @participant_profile = participant_profile
        @cpd_lead_provider = cpd_lead_provider
        @declaration_date = declaration_date
      end
    end
  end

  describe "#validate" do
    subject { klass.new(participant_profile:, cpd_lead_provider:, declaration_date:) }

    context "NPQ participant" do
      let(:participant_profile) { create(:npq_participant_profile) }
      let(:npq_application) { participant_profile.npq_application }
      let(:cpd_lead_provider) { npq_application.npq_lead_provider.cpd_lead_provider }
      let(:declaration_date) { Time.zone.now + 1.day }

      context "participant profile active" do
        it { is_expected.to be_valid }
      end

      context "participant profile withdrawn before declaration_date" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn) }

        it { is_expected.to be_invalid }
      end

      context "participant profile withdrawn after declaration_date" do
        let(:declaration_date) { Time.zone.now - 1.day }
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn) }

        it { is_expected.to be_valid }
      end

      context "participant profile reinstated after being withdrawn" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn) }
        let(:course_identifier) { participant_profile.npq_application.npq_course.identifier }

        before do
          ResumeParticipant.new(
            cpd_lead_provider:,
            participant_id: participant_profile.participant_identity.external_identifier,
            course_identifier:,
          ).call
        end

        it { is_expected.to be_valid }
      end
    end

    context "ECF participant" do
      let(:participant_profile) { create :mentor }
      let(:cpd_lead_provider) { participant_profile.lead_provider.cpd_lead_provider }
      let(:declaration_date) { Time.zone.now + 1.day }

      context "participant profile active" do
        it { is_expected.to be_valid }
      end

      context "participant profile withdrawn before declaration_date" do
        let(:participant_profile) { create :mentor, :withdrawn }

        it { is_expected.to be_invalid }
      end

      context "participant profile withdrawn after declaration_date" do
        let(:participant_profile) { create :mentor, :withdrawn }
        let(:declaration_date) { Time.zone.now - 1.day }

        it { is_expected.to be_valid }
      end

      context "participant profile reinstated after being withdrawn" do
        let(:participant_profile) { create :mentor, :withdrawn }

        before do
          ResumeParticipant.new(
            cpd_lead_provider:,
            participant_id: participant_profile.participant_identity.external_identifier,
            course_identifier: "ecf-mentor",
          ).call
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
