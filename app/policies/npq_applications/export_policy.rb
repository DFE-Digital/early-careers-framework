# frozen_string_literal: true

module NPQApplications
  class ExportPolicy < ApplicationPolicy
    def index?
      admin?
    end

    def new?
      admin?
    end

    def create?
      admin?
    end

    class Scope < Scope
      def resolve
        return scope.all if user.admin?

        scope.none
      end
    end
  end
end
