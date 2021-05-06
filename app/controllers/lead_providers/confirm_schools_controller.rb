# frozen_string_literal: true

module LeadProviders
  class ConfirmSchoolsController < ApplicationController
    before_action :load_form

    def show
      render :no_schools and return if @confirm_schools_form.school_ids.none?

      @schools = School.includes(:local_authority).find(@confirm_schools_form.school_ids)
      @delivery_partner = @confirm_schools_form.delivery_partner
      @cohort = Cohort.find(@confirm_schools_form.cohort_id)
    end

    def remove
      school_id = params[:remove][:school_id]
      @confirm_schools_form.school_ids.delete(school_id)

      if @confirm_schools_form.school_ids.any?
        school = School.find school_id
        set_success_message heading: "#{school.name} has been removed"
      end

      redirect_to action: :show
    end

    def confirm
      @confirm_schools_form.save!

      redirect_to success_lead_providers_report_schools_path
    end

  private

    def load_form
      if session[:partnership_csv_upload_id].present?
        load_partnership_csv_upload
      elsif session[:confirm_schools_form].present?
        @confirm_schools_form = ConfirmSchoolsForm.new(session[:confirm_schools_form])
      end
    end

    def load_partnership_csv_upload
      partnership_csv_upload = PartnershipCsvUpload.find(session[:partnership_csv_upload_id])
      session.delete(:partnership_csv_upload_id)
      @confirm_schools_form = ConfirmSchoolsForm.new(
        lead_provider_id: partnership_csv_upload.lead_provider.id,
        delivery_partner_id: partnership_csv_upload.delivery_partner.id,
        school_ids: partnership_csv_upload.valid_schools.pluck(:id),
        source: "csv",
        cohort_id: Cohort.current.id,
      )
      session[:confirm_schools_form] = @confirm_schools_form
    end
  end
end
