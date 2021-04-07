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

  def number_of_participants_status
    if estimated_teacher_count.present? && estimated_mentor_count.present?
      "done"
    else
      "to do"
    end
  end

  def training_provider_status
    if school.partnerships.exists?(cohort: cohort)
      "done"
    else
      "to do"
    end
  end

  def accept_legal_status
    "cannot start yet"
  end

  def add_participants_status
    "cannot start yet"
  end

  def choose_training_materials_status
    "cannot start yet"
  end

  def status
    if school_chose_cip?
      cip_status
    else
      fip_status
    end
  end

  def school_chose_cip?
    induction_programme_choice == "core_induction_programme"
  end

private

  def cip_status
    if choose_training_materials_status == "done" && add_participants_status == "done"
      "done"
    else
      "to do"
    end
  end

  def fip_status
    if number_of_participants_status == "done" && training_provider_status == "done" &&
        accept_legal_status == "done" && add_participants_status == "done"
      "done"
    else
      "to do"
    end
  end
end
