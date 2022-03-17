# frozen_string_literal: true

module Api
  module V2
    class NPQEnrollmentsCsvSerializer
      attr_reader :scope

      def initialize(scope:)
        @scope = scope
      end

      def call
        CSV.generate do |csv|
          csv << headers

          scope.each do |object|
            row = [
              object.user.id,
              object.npq_course.identifier,
              object.schedule.schedule_identifier,
              object.schedule.cohort.start_year.to_s,
              object.npq_application.id,
              object.npq_application.eligible_for_funding,
              object.training_status,
              object.school_urn,
            ]

            csv << row
          end
        end
      end

    private

      def headers
        %w[
          participant_id
          course_identifier
          schedule_identifier
          cohort
          npq_application_id
          eligible_for_funding
          training_status
          school_urn
        ]
      end
    end
  end
end
