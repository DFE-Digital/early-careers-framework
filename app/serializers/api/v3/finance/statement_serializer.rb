# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    module Finance
      class StatementSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        set_id :id
        set_type :statement

        attribute :month do |statement|
          statement.name[/([^\s]+)/]
        end

        attribute :year do |statement|
          statement.name[/(\d+)/]
        end

        attribute :type do |statement|
          case statement
          when ::Finance::Statement::ECF
            "ecf"
          when ::Finance::Statement::NPQ
            "npq"
          end
        end

        attribute :cohort do |statement|
          statement.cohort.start_year.to_s
        end

        attribute :cut_off_date do |statement|
          statement.deadline_date.rfc3339
        end

        attribute :payment_date do |statement|
          statement.payment_date.rfc3339
        end

        attribute :paid, &:paid?
      end
    end
  end
end
