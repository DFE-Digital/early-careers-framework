# frozen_string_literal: true

module NPQ
  class BuildApplication
    class << self
      def call(npq_application_params:, npq_course_id:, npq_lead_provider_id:, user_id:)
        new(
          npq_application_params:,
          npq_course_id:,
          npq_lead_provider_id:,
          user_id:,
        ).npq_application
      end
    end

    def npq_application
      @npq_application ||= NPQApplication.new(npq_application_attributes)
    end

    def initialize(
      npq_application_params:,
      npq_course_id:,
      npq_lead_provider_id:,
      user_id:
    )
      self.npq_application_params = npq_application_params
      self.npq_course_id          = npq_course_id
      self.npq_lead_provider_id   = npq_lead_provider_id
      self.user_id                = user_id
    end

  private

    attr_accessor :npq_application_params, :npq_course_id, :npq_lead_provider_id, :user_id

    def npq_application_attributes
      npq_application_params.except(:user_id, :cohort).merge(
        npq_course:,
        npq_lead_provider:,
        participant_identity:,
        cohort:,
        teacher_catchment_iso_country_code:,
      )
    end

    def teacher_catchment_country
      npq_application_params[:teacher_catchment_country]
    end

    def teacher_catchment_iso_country_code
      return if teacher_catchment_country.blank?

      if (country = ISO3166::Country.find_country_by_iso_short_name(teacher_catchment_country))
        country.alpha3
      else
        Sentry.capture_message("Could not find the ISO3166 alpha3 code for #{teacher_catchment_country}.")
      end
    end

    def cohort
      @cohort ||= Cohort.find_by(start_year: npq_application_params[:cohort])
    end

    def npq_course
      NPQCourse.find_by(id: npq_course_id)
    end

    def npq_lead_provider
      NPQLeadProvider.find_by(id: npq_lead_provider_id)
    end

    def user
      Identity.find_user_by(id: user_id)
    end

    def participant_identity
      Identity::Create.call(user:, origin: :npq) if user_id.present?
    end
  end
end
