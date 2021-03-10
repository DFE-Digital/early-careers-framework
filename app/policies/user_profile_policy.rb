# frozen_string_literal: true

class UserProfilePolicy < ApplicationPolicy
  def index?
    admin_only
  end

  class Scope < Scope
    def resolve
      scope.kept
    end
  end
end
