# frozen_string_literal: true

module Finance
  module ECF
    class OutputCalculator
      DECLARATION_TYPE_FEE_PROPORTIONS = {
        started: 0.2,
        completed: 0.2,
        retained_1: 0.15,
        retained_2: 0.15,
        retained_3: 0.15,
        retained_4: 0.15,
        extended_1: 0.15,
        extended_2: 0.15,
        extended_3: 0.15,
      }.freeze

      attr_reader :statement

      def initialize(statement:)
        @statement = statement
      end

      def banding_for(declaration_type:)
        bandings[declaration_type]
      end

      def uplift
        @uplift ||= self.class.module_parent::UpliftCalculator.new(statement:)
      end

      def fee_for_declaration(band_letter:, type:)
        percentage = DECLARATION_TYPE_FEE_PROPORTIONS[type]
        percentage * band_for_letter(band_letter).output_payment_per_participant
      end

    private

      def bandings
        @bandings ||= declaration_types.index_with do |declaration_type|
          self.class.module_parent::BandingCalculator.new(statement:, declaration_type:)
        end
      end

      def band_for_letter(letter)
        @band_for_letters ||= bands.zip(:a..:d).each_with_object({}) { |(band, lettr), hash| hash[lettr] = band }
        @band_for_letters[letter]
      end

      def declaration_types
        %w[
          started
          retained-1
          retained-2
          retained-3
          retained-4
          completed
          extended-1
          extended-2
          extended-3
        ]
      end

      def bands
        statement.contract.bands.order(max: :asc)
      end
    end
  end
end
