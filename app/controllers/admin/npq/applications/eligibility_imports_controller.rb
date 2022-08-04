# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class EligibilityImportsController < Admin::BaseController
        skip_after_action :verify_policy_scoped, except: %i[index show]

        def example
          authorize ::NPQApplications::EligibilityImport

          respond_to do |format|
            format.csv
          end
        end

        def index
          authorize ::NPQApplications::EligibilityImport

          all_imports = policy_scope(::NPQApplications::EligibilityImport).new_to_old
          @pagy, @eligibility_imports = pagy_array(all_imports, page: params[:page], items: 20)
          @page = @pagy.page
          @total_pages = @pagy.pages
        end

        def show
          authorize ::NPQApplications::EligibilityImport

          @eligibility_import = policy_scope(::NPQApplications::EligibilityImport).find(params[:id])
        end

        def new
          authorize ::NPQApplications::EligibilityImport

          @eligibility_import = ::NPQApplications::EligibilityImport.new
        end

        def create
          authorize ::NPQApplications::EligibilityImport

          @eligibility_import = ::NPQApplications::EligibilityImport.new(import_params.merge(user: current_user))

          if @eligibility_import.save
            @eligibility_import.perform_later

            set_success_message heading: "Import scheduled"
            redirect_to admin_npq_applications_eligibility_imports_url
          else
            render :new
          end
        end

      private

        def import_params
          params.require(:npq_applications_eligibility_import).permit(:filename)
        end
      end
    end
  end
end
