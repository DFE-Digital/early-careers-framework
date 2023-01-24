# frozen_string_literal: true

module Admin
  module Testing
    class OverviewController < Admin::Testing::BaseController
      def index
        # list our assets in development env
        @schools_without_sits = schools_without_sits
        @schools_doing_fip = []
        @schools_doing_cip = []
      end

      def show
      end

    private

      def schools_without_sits
        policy_scope(School).where.missing(:induction_coordinator_profiles_schools).order(:urn)
      end
    end
  end
end
