# frozen_string_literal: true

class InductionProgramme < ApplicationRecord
  has_paper_trail

  enum training_programme: {
    full_induction_programme: "full_induction_programme",
    core_induction_programme: "core_induction_programme",
    design_our_own: "design_our_own",
    school_funded_fip: "school_funded_fip",
  }

  belongs_to :school_cohort
  belongs_to :partnership, optional: true
  belongs_to :core_induction_programme, optional: true

  has_many :induction_records
  has_many :active_induction_records, -> { active }, class_name: "InductionRecord"
  has_many :transferring_in_induction_records, -> { transferring_in }, class_name: "InductionRecord"
  has_many :transferring_out_induction_records, -> { transferring_out }, class_name: "InductionRecord"
  has_many :transferred_induction_records, -> { transferred }, class_name: "InductionRecord"
  has_many :participant_profiles, through: :active_induction_records
  has_many :current_induction_records, -> { current }, class_name: "InductionRecord"
  has_many :current_participant_profiles, through: :current_induction_records, source: :participant_profile

  delegate :school, to: :school_cohort

  def lead_provider
    school_cohort&.lead_provider
  end

  def delivery_partner
    school_cohort&.delivery_partner
  end
end
