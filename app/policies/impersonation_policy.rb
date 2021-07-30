# frozen_string_literal: true

class ImpersonationPolicy < ApplicationPolicy
  def create?
    admin_only && !self_impersonation && !admin_impersonation
  end

  def destroy?
    admin_only && !self_impersonation && !admin_impersonation
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.none
    end
  end

private

  def self_impersonation
    @record&.id == user.id
  end

  def admin_impersonation
    @record&.admin?
  end
end
