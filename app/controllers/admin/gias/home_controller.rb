# frozen_string_literal: true

module Admin
  module Gias
    class HomeController < Admin::BaseController
      before_action { authorize :gias }

      def index
        @schools_to_open_count = schools_to_open_count
        @schools_to_close_count = schools_to_close_count
        @schools_with_changes_count = schools_with_changes_count
      end

    private

      def schools_to_open_count
        schools_scope.schools_to_add.count + schools_scope.schools_to_open.count
      end

      def schools_to_close_count
        schools_scope.schools_to_close.count
      end

      def schools_with_changes_count
        schools_scope.schools_with_changes.count
      end

      def schools_scope
        policy_scope(DataStage::School, policy_scope_class: GiasPolicy::Scope)
      end
    end
  end
end
