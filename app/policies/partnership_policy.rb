# frozen_string_literal: true

class PartnershipPolicy < ApplicationPolicy
  def update?
    return true if admin?
    return false unless user&.induction_coordinator?

    user.schools.include?(record.school)
  end

  def challenge?
    super_user?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
