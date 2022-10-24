# frozen_string_literal: true

module Finance
  module ECF
    module Duplicates
      class CompareController < BaseController
        def show
          @primary_profile = Duplicate.find(params[:id])
          @duplicate_profile = Duplicate.find(params[:duplicate_id])
          @breadcrumbs = [
            helpers.govuk_breadcrumb_link_to("Finance dashboard", finance_landing_page_path),
            helpers.govuk_breadcrumb_link_to("Search records", finance_ecf_duplicates_path),
            helpers.govuk_breadcrumb_link_to(@primary_profile.user.full_name, finance_ecf_duplicate_path(@primary_profile)),
            helpers.govuk_breadcrumb_link_to("Details", finance_ecf_duplicate_compare_path(@duplicate_profile, @primary_profile)),
          ]
        end
      end
    end
  end
end
