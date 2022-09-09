# frozen_string_literal: true

module Mentors
  class ChangeSchool < BaseService
    def call
      ActiveRecord::Base.transaction do
        AddToSchool.call(mentor_profile:, school: to_school, preferred_email:)
        RemoveFromSchool.call(mentor_profile:, school: from_school, remove_on_date:)
      end
    end

  private

    attr_reader :mentor_profile, :from_school, :to_school, :remove_on_date, :preferred_email

    def initialize(mentor_profile:, from_school:, to_school:, preferred_email: nil, remove_on_date: nil)
      @mentor_profile = mentor_profile
      @from_school = from_school
      @to_school = to_school
      @preferred_email = preferred_email
      @remove_on_date = remove_on_date
    end
  end
end
