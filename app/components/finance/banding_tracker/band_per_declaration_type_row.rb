# frozen_string_literal: true

module Finance
  module BandingTracker
    class BandPerDeclarationTypeRow < BaseComponent
      with_collection_parameter :band

      def initialize(band:, aggregator:)
        self.aggregator = aggregator
        self.band       = band
      end

      def started
        count_for_declaration_type("started")
      end

      def retrained_one
        count_for_declaration_type("retained-1")
      end

      def retrained_two
        count_for_declaration_type("retained-2")
      end

      def retrained_three
        count_for_declaration_type("retained-3")
      end

      def retrained_four
        count_for_declaration_type("retained-4")
      end

      def completed
        count_for_declaration_type("completed")
      end

      def band_name
        case band.call_off_contract.bands.index(band)
        when 0 then "Band A"
        when 1 then "Band B"
        when 2 then "Band C"
        when 3 then "Band D"
        end
      end

    private

      attr_accessor :aggregator, :band

      def count_for_declaration_type(declaration_type)
        aggregator
          .participants_for_declaration_type_in_band(
            declaration_type: declaration_type, band: band,
          )
      end
    end
  end
end
