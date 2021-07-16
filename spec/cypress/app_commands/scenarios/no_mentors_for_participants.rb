# frozen_string_literal: true

# expects "school_participants" to have been previously run

school = School.find_by(name: "Hogwarts Academy")

if school.present?
  school.participant_profiles.mentors.each do |profile|
    profile.user.destroy!
  end
end
