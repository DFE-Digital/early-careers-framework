# frozen_string_literal: true

module Migration
  class ParityCheck::TokenProvider
    class UnsupportedEnvironmentError < RuntimeError; end

    def generate!
      raise UnsupportedEnvironmentError, "The parity check functionality is disabled for this environment" unless enabled?

      known_tokens_by_lead_provider_ecf_id.each do |id, token|
        cpd_lead_provider = NPQLeadProvider.find_by!(id:).cpd_lead_provider
        create_with_known_token!(token:, cpd_lead_provider:) if cpd_lead_provider
      end
    end

  private

    def known_tokens_by_lead_provider_ecf_id
      JSON.parse(ENV["PARITY_CHECK_KEYS"].to_s)
    rescue JSON::ParserError
      {}
    end

    def create_with_known_token!(token:, cpd_lead_provider:)
      LeadProviderApiToken.create_with_known_token!(token, cpd_lead_provider:)
    end

    def enabled?
      Rails.env.migration?
    end
  end
end
