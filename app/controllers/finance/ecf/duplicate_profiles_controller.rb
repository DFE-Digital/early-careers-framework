module Finance
  module ECF
    class DuplicateProfilesController < BaseController
      def index
        @search_form = Duplicate
                         .ransack(
                           search_params,
                           search_key: :duplicate_search_form,
                         )
        @duplicates = @search_form.result
        @training_statuses = Duplicate.select(:training_status).distinct
        @induction_statuses = Duplicate.select(:induction_status).distinct
      end

      def show
        @duplicate = Duplicate.find(params[:id])

      end
    private

      def search_params
        return {} unless params.key?(:duplicate_search_form)

        params.require(:duplicate_search_form)
          .permit(:participant_id_eq, :training_status_eq, :induction_status_eq)
      end
    end
  end
end
