# frozen_string_literal: true

class SchoolCohort < ApplicationRecord
  enum induction_programme_choice: {
    funded_training_provider: "funded_training_provider",
    free_development_materials: "free_development_materials",
    design_our_own: "design_our_own",
    not_yet_known: "not_yet_known",
  }

  belongs_to :cohort
  belongs_to :school
end
