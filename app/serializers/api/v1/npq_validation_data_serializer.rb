# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class NPQValidationDataSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :npq_profiles

      attributes :date_of_birth,
                 :teacher_reference_number,
                 :teacher_reference_number_verified,
                 :active_alert,
                 :school_urn,
                 :school_ukprn,
                 :headteacher_status,
                 :eligible_for_funding,
                 :funding_choice
    end
  end
end
