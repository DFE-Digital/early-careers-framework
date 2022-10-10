# frozen_string_literal: true

class AppropriateBodyProfilePolicy < ApplicationPolicy
  def index?
    admin_only
  end

  def show?
    admin_only
  end

  def create?
    admin_only
  end

  def update?
    admin_only
  end

  def destroy?
    admin_only
  end

  def admin_only
    FeatureFlag.active?(:appropriate_bodies) && !!user&.admin?
  end

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?

      scope.none
    end
  end
end
