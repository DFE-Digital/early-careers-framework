# frozen_string_literal: true

class School < ApplicationRecord
  has_paper_trail

  extend FriendlyId
  include GiasHelpers

  friendly_id :slug_candidates

  belongs_to :network, optional: true

  has_many :training_record_states
  has_many :npq_applications, foreign_key: "school_urn", class_name: "NPQApplication"
  has_many :school_links, dependent: :destroy
  has_many :successor_links, -> { successor }, class_name: "SchoolLink"
  has_many :predecessor_links, -> { predecessor }, class_name: "SchoolLink"
  has_many :successor_schools, through: :successor_links, source: :link_school
  has_many :predecessor_schools, through: :predecessor_links, source: :link_school

  has_many :school_local_authorities
  has_many :local_authorities, through: :school_local_authorities
  has_one :latest_school_authority, -> { latest }, class_name: "SchoolLocalAuthority"
  has_one :local_authority, through: :latest_school_authority

  has_many :school_local_authority_districts
  has_many :local_authority_districts, through: :school_local_authority_districts
  has_one :latest_school_authority_district, -> { latest }, class_name: "SchoolLocalAuthorityDistrict"
  has_one :local_authority_district, through: :latest_school_authority_district

  has_many :partnerships
  has_many :active_partnerships, -> { active }, class_name: "Partnership"
  has_many :lead_providers, through: :partnerships
  has_many :school_cohorts
  has_many :pupil_premiums
  has_many :nomination_emails, -> { order(created_at: :desc) }

  has_many :induction_coordinator_profiles_schools, dependent: :destroy
  has_many :induction_coordinator_profiles, through: :induction_coordinator_profiles_schools
  has_many :induction_coordinators, through: :induction_coordinator_profiles, source: :user

  has_many :school_mentors, dependent: :destroy
  has_many :mentor_profiles, through: :school_mentors, source: :participant_profile

  has_many :current_induction_records, through: :school_cohorts, class_name: "InductionRecord"

  has_many :ecf_participant_profiles, through: :school_cohorts, source: :ecf_participant_profiles, class_name: "ParticipantProfile::ECF"
  has_many :ecf_participants, through: :ecf_participant_profiles, source: :user
  has_many :active_ecf_participant_profiles, through: :school_cohorts
  has_many :active_ecf_participants, through: :active_ecf_participant_profiles, source: :user

  has_many :additional_school_emails

  scope :with_local_authority, lambda { |local_authority|
    joins(%i[school_local_authorities local_authorities])
      .where(school_local_authorities: { end_year: nil }, local_authorities: local_authority)
  }

  scope :partnered, lambda { |year|
    where(id: Partnership.unchallenged.in_year(year).select(:school_id))
  }

  scope :partnered_with_lead_provider, lambda { |lead_provider_id, year|
    where(id: Partnership.unchallenged.where(lead_provider_id:).in_year(year).select(:school_id))
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

  scope :opted_out, lambda { |cohort = Cohort.current|
    joins(:school_cohorts).where(school_cohorts: { cohort_id: cohort.id, opt_out_of_updates: true })
  }

  scope :all_ecf_participants_validated, lambda {
    left_outer_joins(active_ecf_participant_profiles: %i[ecf_participant_eligibility ecf_participant_validation_data])
      .group(:id)
      .having(<<~SQL)
        SUM(
          CASE
            WHEN COALESCE(ecf_participant_eligibilities.id, ecf_participant_validation_data.id) IS NULL
            THEN 1
            ELSE 0
          END
          ) = 0
    SQL
  }

  def partnered?(cohort)
    partnerships.detect { |partnership| partnership.challenged_at.nil? && partnership.challenge_reason.nil? && partnership.cohort_id == cohort.id }.present?
  end

  def lead_provider(year)
    partnerships.unchallenged.where(relationship: false).joins(%i[lead_provider cohort]).find_by(cohorts: { start_year: year })&.lead_provider
  end

  def delivery_partner_for(year)
    partnerships.unchallenged.where(relationship: false).joins(%i[delivery_partner cohort]).find_by(cohorts: { start_year: year })&.delivery_partner
  end

  def participants_for(cohort)
    school_cohorts.find_by(cohort:)&.active_ecf_participants || []
  end

  def early_career_teacher_profiles_for(cohort)
    school_cohorts.find_by(cohort:)&.ecf_participant_profiles&.ects&.active_record || []
  end

  def mentor_profiles_for(cohort)
    school_cohorts.find_by(cohort:)&.ecf_participant_profiles&.mentors&.active_record || []
  end

  def mentors
    User.where(id: mentor_profiles.active_record.joins(:user).select("users.id")).order(:full_name)
  end

  def registered?
    induction_coordinator_profiles.any?
  end

  def not_registered?
    induction_coordinator_profiles.none?
  end

  def chosen_programme?(cohort)
    school_cohorts.exists?(cohort:)
  end

  def eligible?
    open? && in_england? && (eligible_establishment_type? || section_41_approved?)
  end

  def cip_only?
    !eligible? && open? && cip_only_establishment_type?
  end

  def can_access_service?
    eligible? || cip_only?
  end

  def pupil_premium_uplift?(start_year)
    pupil_premiums.only_with_uplift(start_year).any?
  end

  def sparsity_uplift?(start_year)
    pupil_premiums.only_with_sparsity(start_year).any?
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

  scope :with_sparsity_uplift, lambda { |start_year|
    joins(:pupil_premiums)
      .merge(PupilPremium.only_with_sparsity(start_year))
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
