# frozen_string_literal: true

module Admin
  module Gias
    class SchoolsController < Admin::BaseController
      before_action { authorize :gias }

      def show
        @school = schools_scope.find_by(urn: params[:id])
      end

    private

      def schools_scope
        policy_scope(DataStage::School, policy_scope_class: GiasPolicy::Scope)
      end
    end
  end
end
