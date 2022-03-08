# frozen_string_literal: true

require "csv"

module Api
  module V1
    class PartnershipCsvSerializer
      attr_reader :scope

      def initialize(scope)
        @scope = scope
      end

      def call
        CSV.generate do |csv|
          csv << csv_headers

          scope.each do |record|
            csv << to_row(record)
          end
        end
      end

    private

      def csv_headers
        %w[
          urn
          name
          delivery_partner
        ]
      end

      def to_row(record)
        [
          record.school.urn,
          record.school.name,
          record.delivery_partner&.name,
        ]
      end
    end
  end
end
