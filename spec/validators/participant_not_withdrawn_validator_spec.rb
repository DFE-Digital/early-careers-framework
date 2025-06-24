# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantNotWithdrawnValidator do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      validates :participant_id, participant_not_withdrawn: true

      attr_reader :participant_profile, :cpd_lead_provider, :declaration_date, :relevant_induction_record

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def initialize(participant_profile:, cpd_lead_provider:, declaration_date:)
        @participant_profile = participant_profile
        @cpd_lead_provider = cpd_lead_provider
        @declaration_date = declaration_date
        @relevant_induction_record = participant_profile.latest_induction_record
      end
    end
  end

  describe "#validate" do
    subject { klass.new(participant_profile:, cpd_lead_provider:, declaration_date:) }

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

      context "participant profile withdrawn but `relevant_induction_record` is active" do
        let(:participant_profile) { create :mentor, :withdrawn }

        before do
          create(:induction_record,
                 :active,
                 participant_profile:,
                 induction_programme: participant_profile.latest_induction_record.induction_programme,
                 start_date: Time.zone.now)
        end

        it { is_expected.to be_valid }
      end

      context "participant profile withdrawn but `relevant_induction_record` is not active" do
        let(:participant_profile) { create :mentor, :withdrawn }

        before do
          create(:induction_record,
                 training_status: :withdrawn,
                 participant_profile:,
                 induction_programme: participant_profile.latest_induction_record.induction_programme,
                 start_date: Time.zone.now)
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
