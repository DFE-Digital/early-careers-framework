# frozen_string_literal: true

class LeadProviderProfilePolicy < ApplicationPolicy
  def index?
    admin_only
  end

  def show?
    admin_only
  end

  def destroy?
    admin_only
  end

  def create?
    admin_only
  end

  def update?
    admin_only
  end
  def permitted_attributes
    if user.admin?
      :id
    end
  end

  class Scope < Scope
    def resolve
      return scope.kept if user.admin?

      scope.none
    end
  end
end
