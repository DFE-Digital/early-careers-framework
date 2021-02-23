# frozen_string_literal: true

class LeadProvider::ConfirmPartnershipsController < LeadProvider::BaseController
  def create
    skip_authorization
    skip_policy_scope

    @partnership_form = PartnershipForm.new(params.require(:partnership_form).permit(schools: []))

    @schools = School.where(id: @partnership_form.schools)
  end
end
