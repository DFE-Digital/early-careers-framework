# frozen_string_literal: true

class LeadProvider::CreatePartnershipsController < LeadProvider::BaseController
  def create
    skip_authorization
    skip_policy_scope

    @partnership_form = PartnershipForm.new(params.require(:partnership_form).permit(schools: []))

    @schools = School.where(id: @partnership_form.schools)

    ActiveRecord::Base.transaction do
      render "errors/internal_server_error" if @schools.partnered(2021).any?

      @schools.each do |school|
        Partnership.create!(school: school, cohort: current_cohort, lead_provider: lead_provider)
      end
    end
  end

  def current_cohort
    @current_cohort ||= Cohort.find_by(start_year: 2021)
  end

  def lead_provider
    @lead_provider ||= @current_user.lead_provider
  end
end
