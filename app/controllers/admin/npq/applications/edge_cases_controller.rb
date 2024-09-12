# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class EdgeCasesController < Admin::BaseController
        StatusOption = Struct.new(:value, :label)

        skip_after_action :verify_authorized, only: :index
        skip_after_action :verify_policy_scoped, except: :index

        before_action :load_npq_application, except: :index

        def index
          query_string = params[:query]
          funding_eligiblity_status_code = params["Funding eligiblity status code"]
          employment_type = params["Employment type"]
          # Currently the component used is set up to build date parameters in the following manner
          # date(3i) = day, date(2i) = month, date(1i) = year
          start_date = convert_date(params["start_date(3i)"], params["start_date(2i)"], params["start_date(1i)"])
          end_date = convert_date(params["end_date(3i)"], params["end_date(2i)"], params["end_date(1i)"])

          results = Admin::NPQApplications::EdgeCaseSearch
            .new(policy_scope(NPQApplication), query_string:, funding_eligiblity_status_code:, employment_type:, start_date:, end_date:).call

          @pagy, @npq_applications = pagy(results, page: params[:page], limit: 20)
          @page = @pagy.page
          @total_pages = @pagy.pages
        end

        def show; end

      private

        def load_npq_application
          authorize NPQApplication

          @npq_application = NPQApplication
            .eager_load(:profile, participant_identity: :user)
            .find(params[:id])
        end

        def convert_date(day, month, year)
          "#{day}-#{month}-#{year}".to_date
        rescue StandardError
          nil
        end
      end
    end
  end
end
