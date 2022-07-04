# frozen_string_literal: true

class NPQApplicationPolicy < ApplicationPolicy
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
