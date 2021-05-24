# frozen_string_literal: true

module Dqt
  class Api
    class V1
      class QualifiedTeachingStatus
        def initialize(client:)
          self.client = client
        end

        def show(params:)
          mapped_params = {
            trn: params[:teacher_reference_number],
            ni: params[:national_insurance_number],
          }

          response = client.get(path: "/api/qualified-teachers/qualified-teaching-status", params: mapped_params)

          # API returns multiple items but we only ever use the first one. Decided to create a consistent interface here for automated checks rather than spend time creating an abstract interface.
          first_item = response[:data].first

          {
            teacher_reference_number: first_item[:trn],
            full_name: first_item[:name],
            date_of_birth: Date.parse(first_item[:doB]),
            national_insurance_number: first_item[:niNumber],
            qts_date: Date.parse(first_item[:qtsAwardDate]),
            active_alert: first_item[:activeAlert],
          }
        rescue Dqt::Client::ResponseError => e
          if e.response.code == 404
            nil
          else
            raise e
          end
        end

      private

        attr_accessor :client
      end
    end
  end
end
