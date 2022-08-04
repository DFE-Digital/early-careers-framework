# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class ExportsController < Admin::BaseController
        skip_after_action :verify_policy_scoped, except: [:index]

        def index
          authorize ::NPQApplications::Export

          all_exports = policy_scope(::NPQApplications::Export).new_to_old
          @pagy, @exports = pagy_array(all_exports, page: params[:page], items: 20)
          @page = @pagy.page
          @total_pages = @pagy.pages
        end

        def new
          authorize ::NPQApplications::Export

          @export_form = Admin::ApplicationExportsForm.new
        end

        def create
          authorize ::NPQApplications::Export

          @export_form = Admin::ApplicationExportsForm.new(export_params.merge(user: current_user))

          if @export_form.save
            @export_form.npq_application_export.perform_later

            set_success_message heading: "Export scheduled, check secure drive for results"
            redirect_to new_admin_npq_applications_export_url
          else
            render :new
          end
        end

      private

        def export_params
          params.require(:admin_application_exports_form).permit(*Admin::ApplicationExportsForm.permitted_params)
        end
      end
    end
  end
end
