# frozen_string_literal: true

module NewSeeds
  module Scenarios
    class NPQ
      attr_reader :user, :application, :participant_identity, :participant_profile, :npq_lead_provider

      def initialize(user: nil, lead_provider: nil)
        @supplied_user = user
        @supplied_lead_provider = lead_provider
      end

      def build
        @user = @supplied_user || FactoryBot.create(:seed_user, :valid)
        @npq_lead_provider = @supplied_lead_provider || FactoryBot.create(:seed_npq_lead_provider, :valid)

        @participant_identity = user&.participant_identities&.sample ||
          FactoryBot.create(:seed_participant_identity, user:)

        @participant_profile = FactoryBot.create(:seed_npq_participant_profile, user:, participant_identity:)

        self
      end

      def add_application
        raise(StandardError, "no participant_identity, call #build first") if participant_identity.blank?

        @application = FactoryBot.create(:seed_npq_application, :valid, participant_identity:, npq_lead_provider:)

        self
      end

      def add_declaration
        raise(StandardError, "no user, call #build first") if user.blank?

        FactoryBot.create(
          :seed_participant_declaration,
          user:,
          participant_profile:,
          cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
        )

        self
      end
    end
  end
end
