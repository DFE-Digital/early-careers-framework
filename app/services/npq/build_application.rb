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
        teacher_catchment_country:,
        teacher_catchment_iso_country_code:,
      )
    end

    def uk_country
      @uk_country ||= ISO3166::Country.find_country_by_any_name("United Kingdom")
    end

    def teacher_catchment_country
      return uk_country.iso_short_name if in_uk_catchement_area?

      npq_application_params[:teacher_catchment_country]
    end

    def teacher_catchment
      npq_application_params[:teacher_catchment]
    end

    def in_uk_catchement_area?
      NPQApplication::UK_CATCHMENT_AREA.include?(teacher_catchment)
    end

    def teacher_catchment_iso_country_code
      return if teacher_catchment_country.blank?
      return uk_country.alpha3 if in_uk_catchement_area?

      if (country = ISO3166::Country.find_country_by_any_name(teacher_catchment_country))
        country.alpha3
      else
        Sentry.capture_message("Could not find the ISO3166 alpha3 code for #{teacher_catchment_country}.", level: :warning)
        nil
      end
    end

    def cohort
      @cohort ||= Cohort.find_by(start_year: npq_application_params[:cohort]).presence || Cohort.active_npq_registration_cohort
    end

    def npq_course
      @npq_course ||= NPQCourse.find_by(id: npq_course_id)
    end

    def npq_lead_provider
      @npq_lead_provider ||= NPQLeadProvider.find_by(id: npq_lead_provider_id)
    end

    def user
      @user ||= Identity.find_user_by(id: user_id)
    end

    def participant_identity
      @participant_identity ||= Identity::Create.call(user:, origin: :npq) if user_id.present?
    end
  end
end
