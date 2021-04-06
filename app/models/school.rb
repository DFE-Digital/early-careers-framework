# frozen_string_literal: true

class School < ApplicationRecord
  CONFIRMATION_WINDOW = 24
  ELIGIBLE_TYPE_CODES = [1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48].freeze
  ELIGIBLE_STATUS_CODES = [1, 3].freeze

  belongs_to :network, optional: true

  has_many :school_local_authorities
  has_many :local_authorities, through: :school_local_authorities
  has_many :school_local_authority_districts
  has_many :local_authority_districts, through: :school_local_authority_districts

  has_many :partnerships
  has_many :lead_providers, through: :partnerships
  has_many :school_cohorts
  has_many :pupil_premiums
  has_many :nomination_emails
  has_and_belongs_to_many :induction_coordinator_profiles

  has_many :early_career_teacher_profiles
  has_many :early_career_teachers, through: :early_career_teacher_profiles, source: :user

  scope :eligible, -> { open.eligible_establishment_type.in_england }

  scope :with_name_like, lambda { |search_key|
    School.eligible.where("name ILIKE ?", "%#{search_key}%")
  }

  scope :with_urn_like, lambda { |search_key|
    School.eligible.where("urn ILIKE ?", "%#{search_key}%")
  }

  scope :search_by_name_or_urn, lambda { |search_key|
    with_name_like(search_key).or(with_urn_like(search_key))
  }

  scope :with_local_authority, lambda { |local_authority|
    joins(%i[school_local_authorities local_authorities])
      .where(school_local_authorities: { end_year: nil }, local_authorities: local_authority)
  }

  scope :partnered, lambda { |year|
    where(id: Partnership.joins(:cohort).where(cohorts: { start_year: year }).pluck(:school_id))
  }

  scope :partnered_with_lead_provider, lambda { |lead_provider_id|
    where(id: Partnership.where(lead_provider_id: lead_provider_id).pluck(:school_id))
  }

  scope :unpartnered, lambda { |year|
    where.not(id: Partnership.joins(:cohort).where(cohorts: { start_year: year }).pluck(:school_id))
  }

  def lead_provider(year)
    partnerships.joins(%i[lead_provider cohort]).find_by(cohorts: { start_year: year })&.lead_provider
  end

  def full_address
    address = <<~ADDRESS
      #{address_line1}
      #{address_line2}
      #{address_line3}
      #{postcode}
    ADDRESS
    address.squeeze("\n")
  end

  def fully_registered?
    confirmed_induction_coordinators.any?
  end

  def not_registered?
    induction_coordinator_profiles.none?
  end

  def partially_registered?
    return false if fully_registered?

    unconfirmed_induction_coordinators
      &.where("users.confirmation_sent_at > ?", CONFIRMATION_WINDOW.hours.ago)
      &.any?
  end

  def chosen_programme?(cohort)
    school_cohorts.exists?(cohort: cohort)
  end

  def eligible?
    eligible_establishment_type? && open? && in_england?
  end

  def local_authority
    school_local_authorities.latest.first&.local_authority
  end

  def local_authority_district
    school_local_authority_districts.latest.first&.local_authority_district
  end

  def pupil_premium_uplift?(start_year)
    pupil_premiums.find_by(start_year: start_year)&.uplift? || false
  end

  def sparsity_uplift?(year = nil)
    local_authority_district&.sparse?(year) || false
  end

  scope :with_pupil_premium_uplift, lambda { |start_year|
    joins(:pupil_premiums)
      .merge(PupilPremium.only_with_uplift(start_year))
  }

  scope :with_sparsity_uplift, lambda { |year|
    joins(:school_local_authority_districts, :local_authority_districts)
      .merge(LocalAuthorityDistrict.only_with_uplift(year))
  }

private

  def open?
    ELIGIBLE_STATUS_CODES.include?(school_status_code)
  end

  def eligible_establishment_type?
    ELIGIBLE_TYPE_CODES.include?(school_type_code)
  end

  def in_england?
    administrative_district_code.match?(/^[Ee].*/)
  end

  scope :open, -> { where(school_status_code: ELIGIBLE_STATUS_CODES) }
  scope :eligible_establishment_type, -> { where(school_type_code: ELIGIBLE_TYPE_CODES) }
  scope :in_england, -> { where("administrative_district_code ILIKE 'E%'") }

  def unconfirmed_induction_coordinators
    induction_coordinator_profiles
      &.joins(:user)
      &.where(users: { confirmed_at: nil })
  end

  def confirmed_induction_coordinators
    induction_coordinator_profiles
      &.joins(:user)
      &.where&.not(users: { confirmed_at: nil })
  end
end
