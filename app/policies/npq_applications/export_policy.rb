# frozen_string_literal: true

module NPQApplications
  class ExportPolicy < ApplicationPolicy
    def index?
      admin?
    end

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
