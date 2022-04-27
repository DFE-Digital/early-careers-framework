# frozen_string_literal: true

class SchoolCohort < ApplicationRecord
  enum induction_programme_choice: {
    full_induction_programme: "full_induction_programme",
    core_induction_programme: "core_induction_programme",
    design_our_own: "design_our_own",
    school_funded_fip: "school_funded_fip",
    no_early_career_teachers: "no_early_career_teachers",
    not_yet_known: "not_yet_known",
  }

  has_paper_trail

  belongs_to :cohort
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :default_induction_programme, class_name: "InductionProgramme", optional: true

  has_many :ecf_participant_profiles, class_name: "ParticipantProfile"
  has_many :ecf_participants, through: :ecf_participant_profiles, source: :user
  has_many :active_ecf_participant_profiles, -> { ecf.active_record }, class_name: "ParticipantProfile::ECF"
  has_many :active_ecf_participants, through: :active_ecf_participant_profiles, source: :user

  has_many :mentor_profiles, -> { mentors }, class_name: "ParticipantProfile"
  has_many :mentors, through: :mentor_profiles, source: :user
  has_many :active_mentor_profiles, -> { mentors.active_record }, class_name: "ParticipantProfile"
  has_many :active_mentors, through: :active_mentor_profiles, source: :user

  has_many :induction_programmes
  has_many :current_induction_records, through: :induction_programmes, class_name: "InductionRecord"
  has_many :active_induction_records, through: :induction_programmes, class_name: "InductionRecord"
  has_many :transferring_in_induction_records, through: :induction_programmes, class_name: "InductionRecord"
  has_many :transferring_out_induction_records, through: :induction_programmes, class_name: "InductionRecord"
  has_many :transferred_induction_records, through: :induction_programmes, class_name: "InductionRecord"
  has_many :current_participant_profiles, through: :induction_programmes, class_name: "ParticipantProfile::ECF"

  scope :for_year, ->(year) { joins(:cohort).where(cohort: { start_year: year }) }

  delegate :description, to: :cohort

  after_save do |school_cohort|
    unless school_cohort.saved_changes.empty?
      ecf_participant_profiles.touch_all
      ecf_participants.touch_all
    end
  end

  def self.dashboard_cohorts
    joins(:cohort).where("cohorts.start_year BETWEEN 2021 AND ?", Time.zone.now.year).order(start_year: :desc).limit(3)
  end

  def lead_provider
    school.lead_provider(cohort.start_year)
  end

  def delivery_partner
    school.delivery_partner_for(cohort.start_year)
  end

  def school_chose_cip?
    induction_programme_choice == "core_induction_programme"
  end
  alias_method :cip?, :school_chose_cip?

  def school_chose_fip?
    induction_programme_choice == "full_induction_programme"
  end
  alias_method :fip?, :school_chose_fip?

  def school_chose_school_funded_fip?
    induction_programme_choice == "school_funded_fip"
  end

  def can_change_programme?
    induction_programme_choice.in? %w[design_our_own no_early_career_teachers school_funded_fip]
  end
end
