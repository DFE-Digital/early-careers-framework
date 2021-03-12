# frozen_string_literal: true

class PartnershipPolicy < ApplicationPolicy
  def show?
    admin_only
  end

  def update?
    admin_only
  end
end
