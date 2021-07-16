# frozen_string_literal: true

class School < ApplicationRecord
  extend FriendlyId
  include GiasHelpers

  friendly_id :slug_candidates

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

  has_many :participant_profiles, through: :school_cohorts
  has_many :participants, through: :participant_profiles, source: :user

  has_many :additional_school_emails

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

  def partnered?(cohort)
    partnerships.unchallenged.where(cohort: cohort).any?
  end

  def lead_provider(year)
    partnerships.unchallenged.joins(%i[lead_provider cohort]).find_by(cohorts: { start_year: year })&.lead_provider
  end

  def delivery_partner_for(year)
    partnerships.joins(%i[delivery_partner cohort]).find_by(cohorts: { start_year: year })&.delivery_partner
  end

  def participants_for(cohort)
    school_cohorts.find_by(cohort: cohort)&.active_participants || []
  end

  def early_career_teacher_profiles_for(cohort)
    school_cohorts.find_by(cohort: cohort)&.participant_profiles&.ects&.active || []
  end

  def mentor_profiles_for(cohort)
    school_cohorts.find_by(cohort: cohort)&.participant_profiles&.mentors&.active || []
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

  def slug_candidates
    [
      %i[urn name],
    ]
  end

private

  def cip_only_establishment_type?
    CIP_ONLY_TYPE_CODES.include?(school_type_code)
  end
end
