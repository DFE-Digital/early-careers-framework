# frozen_string_literal: true

class CourseYearPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    admin_only
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
