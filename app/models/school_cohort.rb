# frozen_string_literal: true

class SchoolCohort < ApplicationRecord
  enum induction_programme_choice: {
    full_induction_programme: "full_induction_programme",
    core_induction_programme: "core_induction_programme",
    design_our_own: "design_our_own",
    not_yet_known: "not_yet_known",
  }

  belongs_to :cohort
  belongs_to :school
  belongs_to :core_induction_programme, optional: true

  def training_provider_status
    school.partnerships&.unchallenged&.exists?(cohort: cohort) ? "Done" : "To do"
  end

  def add_participants_status
    "Cannot start yet"
  end

  def choose_training_materials_status
    core_induction_programme_id ? "Done" : "To do"
  end

  def status
    if core_induction_programme?
      cip_status
    else
      fip_status
    end
  end

  def school_chose_cip?
    induction_programme_choice == "core_induction_programme"
  end

  def school_chose_fip?
    induction_programme_choice == "full_induction_programme"
  end

private

  def cip_status
    if choose_training_materials_status == "Done" && add_participants_status == "Done"
      "Done"
    else
      "To do"
    end
  end

  def fip_status
    if training_provider_status == "Done" && add_participants_status == "Done"
      "Done"
    else
      "To do"
    end
  end
end
