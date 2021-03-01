# frozen_string_literal: true

class LeadProvider::ConfirmPartnershipsController < LeadProvider::BaseController
  skip_after_action :verify_policy_scoped
  def create
    authorize Partnership, :create?

    @partnership_form = PartnershipForm.new(params.require(:partnership_form).permit(schools: []))

    @schools = School.where(id: @partnership_form.schools)
  end
end
