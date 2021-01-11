# frozen_string_literal: true

class LeadProviderPolicy < ApplicationPolicy
  def create?
    return true if user.admin?

    false
  end

  def update?
    return true if user.admin?

    false
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
