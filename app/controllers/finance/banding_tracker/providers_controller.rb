# frozen_string_literal: true

require "finance/banding_tracker/participant_per_declaration_type_per_band_aggregator"

module Finance
  module BandingTracker
    class ProvidersController < BaseController
      def show
        @paid_aggregator    = BandingTracker::ParticipantPerDeclarationTypePerBandAggregator.new(paid_participant_count_per_bands, bands)
        @payable_aggregator = BandingTracker::ParticipantPerDeclarationTypePerBandAggregator.new(payable_participant_count_per_bands, bands)
      end

    private

      def paid_participant_count_per_bands
        @paid_participant_count_per_bands ||= lead_provider
                                                .participant_declarations
                                                .joins(:statement)
                                                .paid
                                                .group(:declaration_type)
                                                .where(statements: { cohort: Cohort.current })
                                                .count
      end

      def payable_participant_count_per_bands
        @payable_participant_count_per_bands ||= lead_provider
                                                   .participant_declarations
                                                   .joins(:statement)
                                                   .payable
                                                   .group(:declaration_type)
                                                   .where(statements: { cohort: Cohort.current })
                                                   .count
      end

      def bands
        @bands ||= lead_provider.call_off_contract.bands
      end

      def lead_provider
        @lead_provider ||= LeadProvider.find(params[:id])
      end
    end
  end
end
