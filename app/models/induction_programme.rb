# frozen_string_literal: true

class InductionProgramme < ApplicationRecord
  has_paper_trail

  enum training_programme: {
    full_induction_programme: "full_induction_programme",
    core_induction_programme: "core_induction_programme",
    design_our_own: "design_our_own",
    school_funded_fip: "school_funded_fip",
    no_early_career_teachers: "no_early_career_teachers",
    not_yet_known: "not_yet_known",
  }

  belongs_to :school_cohort
  belongs_to :partnership, optional: true
  belongs_to :core_induction_programme, optional: true

  delegate :school, to: :school_cohort

  def lead_provider
    partnership&.lead_provider
  end

  def delivery_partner
    partnership&.delivery_partner
  end
end
