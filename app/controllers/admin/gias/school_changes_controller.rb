# frozen_string_literal: true

module Admin
  module Gias
    class SchoolChangesController < Admin::BaseController
      before_action { authorize :gias }

      def index
        @schools = schools_scope.includes(:school_changes)
          .where(school_changes: { status: :changed, handled: false })
      end

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
