# frozen_string_literal: true

# == Schema Information
#
# Table name: pupil_premiums
#
#  id              :uuid             not null, primary key
#  eligible_pupils :integer          not null
#  start_year      :integer          not null
#  total_pupils    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :uuid             not null
#
# Indexes
#
#  index_pupil_premiums_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class PupilPremium < ApplicationRecord
  THRESHOLD_PERCENTAGE = 40

  belongs_to :school

  def uplift?
    percentage_eligible >= THRESHOLD_PERCENTAGE
  end

  scope :only_with_uplift, lambda { |start_year|
    where(start_year: start_year)
      .where("total_pupils > 0 AND (CAST(eligible_pupils AS float) / total_pupils) * 100 >= ?", THRESHOLD_PERCENTAGE)
  }

private

  def percentage_eligible
    (eligible_pupils.to_f / total_pupils) * 100
  end
end
