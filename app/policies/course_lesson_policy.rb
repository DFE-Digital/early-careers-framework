# frozen_string_literal: true

class CourseLessonPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    true
  end

  def create?
    admin_only
  end

  def edit?
    admin_only
  end

  def update?
    admin_only
  end

private

  def admin_only
    return true if user&.admin?

    false
  end
end
