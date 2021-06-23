# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort
  belongs_to :mentor_profile, optional: true
  has_one :mentor, through: :mentor_profile, source: :user
  has_one :participation_record, dependent: :destroy
  has_many :participant_declarations

  # Would like to move the following once we have a refactor on the multistep, which currently leaves either this
  # approach, or changing the form.save! as options. This was chosen to make it obvious that it's separate from the
  # R&P code, since it's only required for uplift payment.
  # This is only required the first time a profile is created, since it shouldn't change even if the underlying
  # school uplift payment scope changes.
  before_save :set_uplift_payment_flags, if: :new_record?

  def set_uplift_payment_flags
    self.sparsity_uplift = school.sparsity_uplift?(cohort.start_year)
    self.pupil_premium_uplift = school.pupil_premium_uplift?(cohort.start_year)
  end
end
