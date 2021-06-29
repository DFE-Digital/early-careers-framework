# frozen_string_literal: true

class PopulateParticipantProfiles < ActiveRecord::Migration[6.1]
  class EarlyCareerTeacherProfile < ApplicationRecord
  end

  class MentorProfile < ApplicationRecord
  end

  class ParticipantProfile < ApplicationRecord
    self.inheritance_column = nil
  end

  def up
    MentorProfile.find_each do |ect_profile|
      ParticipantProfile.create!(
        id: ect_profile.id,
        type: "ParticipantProfile::Mentor",
        user_id: ect_profile.user_id,
        school_id: ect_profile.school_id,
        cohort_id: ect_profile.cohort_id,
        core_induction_programme_id: ect_profile.core_induction_programme_id,
      )
    end

    EarlyCareerTeacherProfile.find_each do |ect_profile|
      ParticipantProfile.create!(
        id: ect_profile.id,
        type: "ParticipantProfile::ECT",
        user_id: ect_profile.user_id,
        school_id: ect_profile.school_id,
        cohort_id: ect_profile.cohort_id,
        sparsity_uplift: ect_profile.sparsity_uplift,
        pupil_premium_uplift: ect_profile.pupil_premium_uplift,
        core_induction_programme_id: ect_profile.core_induction_programme_id,
        mentor_profile_id: ect_profile.mentor_profile_id,
      )
    end
  end
end
