# frozen_string_literal: true

module Admin
  module Archive
    class TableRow < BaseComponent
      with_collection_parameter :relic

      def initialize(relic:)
        @relic = relic
      end

      def email
        relic.data.dig("meta", "email")
      end

      def full_name
        relic.data.dig("meta", "full_name")
      end

      def trn
        relic.data.dig("meta", "trn")
      end

    private

      attr_reader :relic

    end
  end
end
