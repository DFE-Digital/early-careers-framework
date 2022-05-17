# frozen_string_literal: true

module Finance
  module BandingTracker
    class ParticipantPerDeclarationTypePerBandAggregator
      DECLARATION_TYPES = %w[completed retained-4 retained-3 retained-2 retained-1 started].freeze

      def initialize(participant_count_per_bands, bands)
        self.bands = bands
        self.data  = {
          "completed" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-4" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-3" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-2" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-1" => Hash[bands.zip(Array.new(bands.size, 0))],
          "started" => Hash[bands.zip(Array.new(bands.size, 0))],
        }

        DECLARATION_TYPES.each do |declaration_type|
          declaration_type_count = participant_count_per_bands.fetch(declaration_type, 0)

          next unless bands.each do |band|
            declaration_type_count -= band.max unless declaration_type_count <= band.max
            data[declaration_type][band] += declaration_type_count
            break if data[declaration_type][band] == band.max
          end
        end
      end

      def participants_for_declaration_type_in_band(declaration_type:, band:)
        data[declaration_type][band]
      end

    private

      attr_accessor :bands, :data
    end
  end
end
