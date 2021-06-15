# frozen_string_literal: true

class School < ApplicationRecord
  ELIGIBLE_TYPE_CODES = [1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48].freeze
  CIP_ONLY_TYPE_CODES = [10, 11, 30, 37].freeze
  ELIGIBLE_STATUS_CODES = [1, 3].freeze

  belongs_to :network, optional: true

  has_many :school_local_authorities
  has_many :local_authorities, through: :school_local_authorities

  has_one :latest_school_authority, -> { latest }, class_name: "SchoolLocalAuthority"
  has_one :local_authority, through: :latest_school_authority

  has_many :school_local_authority_districts
  has_many :local_authority_districts, through: :school_local_authority_districts

  has_many :partnerships
  has_many :lead_providers, through: :partnerships
  has_many :school_cohorts
  has_many :pupil_premiums
  has_many :nomination_emails

  has_many :induction_coordinator_profiles_schools, dependent: :destroy
  has_many :induction_coordinator_profiles, through: :induction_coordinator_profiles_schools
  has_many :induction_coordinators, through: :induction_coordinator_profiles, source: :user

  has_many :early_career_teacher_profiles
  has_many :early_career_teachers, through: :early_career_teacher_profiles, source: :user

  has_many :mentor_profiles
  has_many :mentors, through: :mentor_profiles, source: :user

  has_many :additional_school_emails

  scope :eligible, -> { open.eligible_establishment_type.in_england }

  scope :with_local_authority, lambda { |local_authority|
    joins(%i[school_local_authorities local_authorities])
      .where(school_local_authorities: { end_year: nil }, local_authorities: local_authority)
  }

  scope :partnered, lambda { |year|
    where(id: Partnership.unchallenged.in_year(year).select(:school_id))
  }

  scope :partnered_with_lead_provider, lambda { |lead_provider_id, year|
    where(id: Partnership.unchallenged.where(lead_provider_id: lead_provider_id).in_year(year).select(:school_id))
  }

  scope :unpartnered, lambda { |year|
    where.not(id: Partnership.unchallenged.in_year(year).select(:school_id))
  }

  scope :without_induction_coordinator, lambda {
    left_outer_joins(:induction_coordinators).where(induction_coordinators: { id: nil })
  }

  scope :not_opted_out, lambda { |cohort = Cohort.current|
    left_outer_joins(:school_cohorts).where(school_cohorts: { cohort_id: [cohort.id, nil], opt_out_of_updates: [false, nil] })
  }

  def lead_provider(year)
    partnerships.unchallenged.joins(%i[lead_provider cohort]).find_by(cohorts: { start_year: year })&.lead_provider
  end

  def delivery_partner_for(year)
    partnerships.joins(%i[delivery_partner cohort]).find_by(cohorts: { start_year: year })&.delivery_partner
  end

  def early_career_teacher_profiles_for(year)
    early_career_teacher_profiles.joins(:cohort).where(cohort: { start_year: year })
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

  def registered?
    induction_coordinator_profiles.any?
  end

  def not_registered?
    induction_coordinator_profiles.none?
  end

  def chosen_programme?(cohort)
    school_cohorts.exists?(cohort: cohort)
  end

  def eligible?
    eligible_establishment_type? && open? && in_england?
  end

  def cip_only?
    open? && cip_only_establishment_type?
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

  def characteristics_for(year)
    characteristics = []
    characteristics << "Pupil premium above 40%" if pupil_premium_uplift?(year)
    characteristics << "Remote school" if sparsity_uplift?(year)
    characteristics.join(" and ")
  end

  scope :with_pupil_premium_uplift, lambda { |start_year|
    joins(:pupil_premiums)
      .merge(PupilPremium.only_with_uplift(start_year))
  }

  scope :with_sparsity_uplift, lambda { |year|
    joins(:school_local_authority_districts, :local_authority_districts)
      .merge(LocalAuthorityDistrict.only_with_uplift(year))
  }

  def contact_email
    if induction_coordinators.any?
      induction_tutor.email
    else
      primary_contact_email.presence || secondary_contact_email
    end
  end

  def induction_tutor
    induction_coordinators.first
  end

private

  def open?
    ELIGIBLE_STATUS_CODES.include?(school_status_code)
  end

  def eligible_establishment_type?
    ELIGIBLE_TYPE_CODES.include?(school_type_code)
  end

  def cip_only_establishment_type?
    CIP_ONLY_TYPE_CODES.include?(school_type_code)
  end

  def in_england?
    administrative_district_code.match?(/^[Ee]/)
  end

  scope :open, -> { where(school_status_code: ELIGIBLE_STATUS_CODES) }
  scope :eligible_establishment_type, -> { where(school_type_code: ELIGIBLE_TYPE_CODES) }
  scope :in_england, -> { where("administrative_district_code ILIKE 'E%'") }
end
