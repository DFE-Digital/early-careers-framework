# frozen_string_literal: true

module LeadProviders
  module ReportSchools
    class BaseController < ::LeadProviders::BaseController
      SESSION_KEY = :lp_report_schools_form

      before_action :set_cohort
      after_action :store_form
      after_action :clean_form!, only: :success

      helper_method :report_schools_form

      def start
        clean_form!
        report_schools_form.cohort_id = @cohort&.id || Cohort.next&.id
        report_schools_form.lead_provider_id = current_user.lead_provider_profile.lead_provider.id
      end

      def create
        report_schools_form.save!

        redirect_to action: :success
      end

      def success; end

    private

      def set_cohort
        @cohort = current_user.lead_provider.cohorts.find_by(start_year: params[:cohort])
      end

      def clean_form!
        session.delete(SESSION_KEY)
      end

      def report_schools_form
        @report_schools_form ||= ReportSchoolsForm.new(session[SESSION_KEY])
      end

      def store_form
        session[SESSION_KEY] = report_schools_form.attributes
      end
    end
  end
end
