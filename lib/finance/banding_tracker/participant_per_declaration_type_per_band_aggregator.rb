# frozen_string_literal: true

module Finance
  module BandingTracker
    class ParticipantPerDeclarationTypePerBandAggregator
      ORDERED_DECLARATION_TYPE = %w[completed retained-4 retained-3 retained-2 retained-1 started].freeze

      def initialize(participant_count_per_bands, bands)
        self.slots_per_declaration_type = sort_and_populate_slots(participant_count_per_bands)
        self.bands                      = bands
        self.data                       = {}
        bands.each do |band|
          data[band] ||= ActiveSupport::HashWithIndifferentAccess.new { 0 }
          next if left_in_band(band).zero?

          slots_per_declaration_type.each do |declaration_type, slots|
            next if !slots_left_in_band?(band) || slots.empty?

            range = 0..(last_band?(band) ? -1 : (left_in_band(band) - 1))
            data[band][declaration_type] = slots.slice!(range).size
            next if slots_left_in_band?(band)
          end
        end
      end

      def participants_for_declaration_type_in_band(declaration_type:, band:)
        data[band][declaration_type]
      end

    private

      attr_accessor :bands, :data, :slots_per_declaration_type

      def slots_left_in_band?(band)
        return true if last_band?(band)

        left_in_band(band).positive?
      end

      def left_in_band(band)
        return Float::INFINITY if last_band?(band)

        slots_count = data[band].values.inject(:+) || 0
        return band.max - slots_count if first_band?(band)

        band.max - band.min + 1 - slots_count
      end

      def first_band?(band)
        bands[0] == band
      end

      def last_band?(band)
        bands.last == band
      end

      def sort_and_populate_slots(participant_count_per_bands)
        participant_count_per_bands.sort_by { |declaration_type, _count| ORDERED_DECLARATION_TYPE.index(declaration_type) }
          .to_h
          .transform_values { |count| Array.new(count) { 1 } }
      end
    end
  end
end
