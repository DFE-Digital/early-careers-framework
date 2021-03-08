# frozen_string_literal: true

class AdminProfilePolicy < ApplicationPolicy
  def create?
    admin_only
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.none
    end
  end
end
