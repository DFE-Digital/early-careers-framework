# frozen_string_literal: true

class BackfillMentorProfileUpliftData < ActiveRecord::Migration[6.1]
  class MentorProfile < ApplicationRecord
    belongs_to :school
  end

  def up
    MentorProfile.find_each do |profile|
      profile.sparsity_uplift = profile.school.sparsity_uplift?(2021)
      profile.pupil_premium_uplift = profile.school.pupil_premium_uplift?(2021)
      profile.save!
    end
  end
end
