# frozen_string_literal: true

module Finance
  module ECF
    module Duplicates
      class CompareController < BaseController
        def show
          @participant_profile = Duplicate.find(params[:id])
          @duplicate           = Duplicate.find(params[:duplicate_id])
          @induction_records   = @duplicate.induction_records.order(created_at: :desc)
          @breadcrumbs = [
            helpers.govuk_breadcrumb_link_to("Finance dashboard", finance_landing_page_path),
            helpers.govuk_breadcrumb_link_to("Master profiles", finance_ecf_duplicates_path),
            helpers.govuk_breadcrumb_link_to(@participant_profile.user.full_name, finance_ecf_duplicate_path(@participant_profile)),
            helpers.govuk_breadcrumb_link_to(@duplicate.id, finance_ecf_duplicate_compare_path(@duplicate, @participant_profile)),
          ]
        end
      end
    end
  end
end
