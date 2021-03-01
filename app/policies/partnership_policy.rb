# frozen_string_literal: true

class PartnershipPolicy < ApplicationPolicy
  def create?
    return true if user&.admin? || user&.lead_provider?

    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
