# frozen_string_literal: true

class BackfillProfileUpliftData < ActiveRecord::Migration[6.1]
  def up
    EarlyCareerTeacherProfile.find_each do |profile|
      profile.sparsity_uplift = profile.school.sparsity_uplift?(2021)
      profile.pupil_premium_uplift = profile.school.pupil_premium_uplift?(2021)
      profile.save!
    end
  end
end
