# frozen_string_literal: true

class RemoveSchoolMentorJob < ApplicationJob
  def perform
    SchoolMentor.to_be_removed.find_each do |school_mentor|
      Mentors::RemoveFromSchool.call(mentor_profile: school_mentor.participant_profile, school: school_mentor.school)
    end
  end
end
