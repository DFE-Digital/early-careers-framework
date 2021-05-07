# frozen_string_literal: true

module LeadProviders
  class ConfirmSchoolsController < ApplicationController
    before_action :load_form, except: :start

    def show
      render :no_schools and return if @confirm_schools_form.school_ids.none?

      @schools = School.includes(:local_authority).find(@confirm_schools_form.school_ids)
      @delivery_partner = DeliveryPartner.find(@confirm_schools_form.delivery_partner_id)
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

    # TODO: This action exists only for demonstration purpose and should be removed
    # as soon as the CSV/search journey is completed
    def start
      session[:confirm_schools_form] = {
        source: :csv,
        school_ids: School.order(Arel.sql("RANDOM()")).limit(5).where.not(id: Partnership.select(:school_id)).pluck(:id),
        delivery_partner_id: DeliveryPartner.order(Arel.sql("RANDOM()")).first.id,
        cohort_id: Cohort.current.id,
        lead_provider_id: current_user.lead_provider.id,
      }
      redirect_to action: :show
    end

    def confirm
      @confirm_schools_form.save!

      redirect_to success_lead_providers_report_schools_path
    end

  private

    def load_form
      redirect_to dashboard_path unless session[:confirm_schools_form]
      @confirm_schools_form = ConfirmSchoolsForm.new(session[:confirm_schools_form])
    end
  end
end
