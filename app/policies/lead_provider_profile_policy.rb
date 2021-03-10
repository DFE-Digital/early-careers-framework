# frozen_string_literal: true

class LeadProviderProfilePolicy < ApplicationPolicy
  def index?
    admin_only
  end

  def show?
    admin_only
  end

  def create?
    admin_only
  end

  def update?
    admin_only
  end

  class Scope < Scope
    def resolve
      scope.kept
    end
  end
end
