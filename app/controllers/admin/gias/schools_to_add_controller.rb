# frozen_string_literal: true

module Admin
  module Gias
    class SchoolsToAddController < Admin::BaseController
      before_action { authorize :gias }

      def index
        @schools = fetch_schools_to_open
      end

      def show
        @school = schools_scope.find_by(urn: params[:id])
      end

    private

      def schools_scope
        policy_scope(DataStage::School, policy_scope_class: GiasPolicy::Scope)
      end

      def fetch_schools_to_open
        (schools_scope.schools_to_add + schools_scope.schools_to_open)
          .sort_by { |school| school.urn.to_i }
      end
    end
  end
end
