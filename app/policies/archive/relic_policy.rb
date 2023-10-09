# frozen_string_literal: true

module Archive
  class RelicPolicy < ApplicationPolicy
    def index?
      admin_only
    end

    def show?
      admin_only
    end

    class Scope < Scope
      def resolve
        return scope.all if user.admin?

        scope.none
      end
    end
  end
end
