# frozen_string_literal: true

# expects "school_participants" to have been previously run
#
school = School.find_by(name: "Hogwarts Academy")
if school.present?
  school.mentor_profiles.each do |profile|
    ParticipantProfile::ECT.where(mentor_profile: profile).update_all(mentor_profile_id: nil)
    profile.user.destroy!
  end
  school.reload
end
