# frozen_string_literal: true

class DeliveryPartnerProfilePolicy < ApplicationPolicy
  def index?
    !!user&.delivery_partner?
  end

  def show?
    !!user&.delivery_partner?
  end

  class Scope < Scope
    def resolve
      return scope.all if user.delivery_partner?

      scope.none
    end
  end
end
