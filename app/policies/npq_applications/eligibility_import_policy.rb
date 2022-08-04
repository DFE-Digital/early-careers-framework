# frozen_string_literal: true

module NPQApplications
  class EligibilityImportPolicy < ApplicationPolicy
    def show?
      admin?
    end

    alias_method :index?, :show?
    alias_method :example?, :show?

    def create?
      admin? && !Rails.env.sandbox?
    end

    alias_method :new?, :create?

    class Scope < Scope
      def resolve
        return scope.all if user.admin?

        scope.none
      end
    end
  end
end
