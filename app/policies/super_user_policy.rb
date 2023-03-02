# frozen_string_literal: true

class SuperUserPolicy < ApplicationPolicy
  def show?
    super_user_only
  end

  class Scope < Scope
    def resolve
      return scope.all if user.super_user?

      scope.none
    end
  end
end
