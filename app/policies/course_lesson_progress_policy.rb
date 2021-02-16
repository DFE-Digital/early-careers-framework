# frozen_string_literal: true

class CourseLessonProgressPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def update?
    @record.user == @user
  end
end
