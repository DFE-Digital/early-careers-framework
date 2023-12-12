# frozen_string_literal: true

lead_provider_api_token = ENV.fetch("PERF_LEAD_PROVIDER_API_TOKEN", "performance-api-token")

cpd_lead_providers = LeadProvider
                       .all
                       .map { |lead_provider| { cpd_lead_provider: lead_provider.cpd_lead_provider, ecf_participants: Api::V3::ECF::ParticipantsQuery.new(lead_provider:, params: {}).participants_for_pagination.length } }

cpd_lead_provider = cpd_lead_providers
                      .max_by { |lead_provider| lead_provider[:ecf_participants] }[:cpd_lead_provider]

LeadProviderApiToken.create_with_known_token!(lead_provider_api_token, cpd_lead_provider:)

Rails.logger.info "Updated ECF training provider api token"
