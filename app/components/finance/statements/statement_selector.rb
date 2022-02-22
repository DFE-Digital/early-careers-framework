# frozen_string_literal: true

module Finance
  module Statements
    class StatementSelector < BaseComponent
      def npq_lead_providers
        NPQLeadProvider.all
      end

      def statements
        Finance::Statement::NPQ
          .distinct(:name)
          .pluck(:name)
          .map do |name|
            OpenStruct.new(
              id: name.downcase.gsub(" ", "-"),
              name: name,
            )
          end
      end
    end
  end
end
