# frozen_string_literal: true

module Api
  module V1
    class NpqProfileResource < JSONAPI::Resource
      attributes :date_of_birth,
                 :teacher_reference_number,
                 :teacher_reference_number_verified,
                 :school_urn,
                 :headteacher_status

      has_one :user
      has_one :npq_lead_provider
      has_one :npq_course
    end
  end
end
