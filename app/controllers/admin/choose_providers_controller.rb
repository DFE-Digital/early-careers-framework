module Admin
  class ChooseProvidersController < Admin::BaseController
    skip_after_action :verify_policy_scoped, only: :create
    skip_after_action :verify_authorized, only: :create

    helper_method :choose_provider_form

    def new
      authorize CpdLeadProvider
      @providers = policy_scope CpdLeadProvider.order(name: :asc)
    end

    def create
      choose_provider_form.attributes = choose_provider_params
      return redirect_to admin_provider_path(id: choose_provider_form.id) if choose_provider_form.valid?

      @providers = policy_scope CpdLeadProvider.order(name: :asc)
      render :new
    end

    private

    def choose_provider_params
      params
        .require(:finance_banding_tracker_choose_provider)
        .permit(:id)
    end

    def ensure_admin
      raise Pundit::NotAuthorizedError, I18n.t(:forbidden) unless current_user.admin?
    end

    def choose_provider_form
      @choose_provider_form ||= Finance::BandingTracker::ChooseProvider.new
    end
  end
end
