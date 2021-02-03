# frozen_string_literal: true

class DeliveryPartnerProfilePolicy < ApplicationPolicy
  def create?
    admin_only
  end

  def update?
    admin_only
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
