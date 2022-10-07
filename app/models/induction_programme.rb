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
  has_many :current_induction_records, -> { current }, class_name: "InductionRecord"
  has_many :transferring_in_induction_records, -> { transferring_in }, class_name: "InductionRecord"
  has_many :transferring_out_induction_records, -> { transferring_out }, class_name: "InductionRecord"
  has_many :transferred_induction_records, -> { transferred }, class_name: "InductionRecord"
  has_many :participant_profiles, through: :active_induction_records
  has_many :current_participant_profiles, through: :current_induction_records, source: :participant_profile
  has_one :lead_provider, through: :partnership
  has_one :delivery_partner, through: :partnership
  has_one :cpd_lead_provider, through: :lead_provider
  delegate :cohort, :school, to: :school_cohort

  after_commit :touch_induction_records

  def lead_provider_name
    lead_provider&.name unless partnership&.challenged?
  end

  def delivery_partner_name
    delivery_partner&.name unless partnership&.challenged?
  end

private

  def touch_induction_records
    current_induction_records.touch_all
  end
end
