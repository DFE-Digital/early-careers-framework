# frozen_string_literal: true

class GiasPolicy < ApplicationPolicy
  def index?
    admin_only
  end

  def show?
    admin_only
  end

  def update?
    admin_only
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.none
    end
  end
end
