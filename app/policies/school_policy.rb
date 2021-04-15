# frozen_string_literal: true

class SchoolPolicy < ApplicationPolicy
  def index?
    admin_only
  end

  def show?
    admin_only
  end

  class Scope < Scope
    def resolve
      return scope.eligible if user.admin?

      scope.none
    end
  end
end
