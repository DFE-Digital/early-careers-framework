# frozen_string_literal: true

module Finance
  module BandingTracker
    class ParticipantPerDeclarationTypePerBandAggregator
      DECLARATION_TYPES = %w[completed retained-4 retained-3 retained-2 retained-1 started].freeze

      def initialize(participant_count_per_bands, bands)
        self.bands = bands
        self.data  = {
          "started" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-1" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-2" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-3" => Hash[bands.zip(Array.new(bands.size, 0))],
          "retained-4" => Hash[bands.zip(Array.new(bands.size, 0))],
          "completed" => Hash[bands.zip(Array.new(bands.size, 0))],
        }

        DECLARATION_TYPES.each do |declaration_type|
          declaration_type_count = participant_count_per_bands.fetch(declaration_type, 0)

          next unless bands.each do |band|
            break unless slots_left_in_band?(declaration_type, band)

            slots_left = left_in_band(declaration_type, band)
            if declaration_type_count <= slots_left
              data[declaration_type][band] += declaration_type_count
              break
            else
              declaration_type_count -= slots_left
              data[declaration_type][band] += slots_left
            end
          end
        end
      end

      def participants_for_declaration_type_in_band(declaration_type:, band:)
        data[declaration_type][band]
      end

    private

      attr_accessor :bands, :data

      def slots_left_in_band?(declaration_type, band)
        return true if last_band?(band)

        left_in_band(declaration_type, band).positive?
      end

      def left_in_band(declaration_type, band)
        return Float::INFINITY if last_band?(band)

        slots_count = data[declaration_type][band]
        return band.max - slots_count if first_band?(band)

        band.max - band.min + 1 - slots_count
      end

      def first_band?(band)
        bands[0] == band
      end

      def last_band?(band)
        bands.last == band
      end
    end
  end
end
