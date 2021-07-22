# frozen_string_literal: true

class FinanceProfilePolicy < ApplicationPolicy
  def index?
    !!user&.finance?
  end

  class Scope < Scope
    def resolve
      return scope.all if user.finance?

      scope.none
    end
  end
end
