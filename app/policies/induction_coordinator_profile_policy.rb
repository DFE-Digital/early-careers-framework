# frozen_string_literal: true

class InductionCoordinatorProfilePolicy < ApplicationPolicy
  def show?
    admin_only
  end

  def index?
    admin_only
  end

  def destroy?
    admin_only
  end

  class Scope < Scope
    def resolve
      scope.kept
    end
  end
end
