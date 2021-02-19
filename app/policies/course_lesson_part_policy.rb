# frozen_string_literal: true

class CourseLessonPartPolicy < ApplicationPolicy
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

  def update?
    admin_only
  end
end
