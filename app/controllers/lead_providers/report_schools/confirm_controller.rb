# frozen_string_literal: true

module LeadProviders
  module ReportSchools
    class ConfirmController < BaseController
      def show
        render :no_schools and return if report_schools_form.school_ids.none?

        @schools = School.includes(:local_authority).find(report_schools_form.school_ids)
        @delivery_partner = report_schools_form.delivery_partner
      end

      def remove_school
        school_id = params[:remove][:school_id]
        report_schools_form.school_ids.delete(school_id)

        if report_schools_form.school_ids.any?
          school = School.find school_id
          set_success_message heading: "#{school.name} has been removed"
        end

        redirect_to action: :show
      end

    private

      def load_form
        @confirm_schools_form = ConfirmSchoolsForm.new(session[:confirm_schools_form])
      end
    end
  end
end
