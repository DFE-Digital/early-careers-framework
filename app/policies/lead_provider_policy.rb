# frozen_string_literal: true

class LeadProviderPolicy < ApplicationPolicy
  def show?
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
      :name
    end
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
