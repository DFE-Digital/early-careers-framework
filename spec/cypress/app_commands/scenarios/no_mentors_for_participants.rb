# frozen_string_literal: true

# expects "school_participants" to have been previously run

school = School.find_by(name: "Hogwarts Academy")

if school.present?
  school.mentor_profiles.each do |profile|
    profile.user.destroy!
  end
end
