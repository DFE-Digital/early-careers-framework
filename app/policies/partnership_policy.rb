# frozen_string_literal: true

class PartnershipPolicy < ApplicationPolicy
  def update?
    user&.induction_coordinator? && user&.schools&.include?(record.school)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
