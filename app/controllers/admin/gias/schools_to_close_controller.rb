# frozen_string_literal: true

module Admin
  module Gias
    class SchoolsToCloseController < Admin::BaseController
      before_action { authorize :gias }

      def index
        @schools = schools_scope.schools_to_close.order(urn: :asc)
      end

    private

      def schools_scope
        policy_scope(DataStage::School, policy_scope_class: GiasPolicy::Scope)
      end
    end
  end
end
