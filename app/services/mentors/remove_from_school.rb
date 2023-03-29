# frozen_string_literal: true

module Mentors
  class RemoveFromSchool < BaseService
    def call
      if remove_on_date.present? && remove_on_date > Time.zone.now
        store_removal_date!
      else
        ActiveRecord::Base.transaction do
          # remove from mentors list at the school
          school_mentor&.destroy!

          # remove from mentees at the school
          InductionRecord.for_school(school).ects.current.where(mentor_profile:).each do |induction_record|
            Mentors::Change.call(induction_record:)
          end
        end
      end
    end

  private

    attr_reader :mentor_profile, :school, :remove_on_date

    def initialize(mentor_profile:, school:, remove_on_date: nil)
      @mentor_profile = mentor_profile
      @school = school
      @remove_on_date = remove_on_date
    end

    def school_mentor
      school.school_mentors.find_by(participant_profile: mentor_profile)
    end

    def store_removal_date!
      school_mentor&.update!(remove_from_school_on: remove_on_date)
    end
  end
end
