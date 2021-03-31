# frozen_string_literal: true

class SchoolCohort < ApplicationRecord
  enum induction_programme_choice: {
    full_induction_programme: "full_induction_programme",
    core_induction_programme: "core_induction_programme",
    design_our_own: "design_our_own",
    not_yet_known: "not_yet_known",
  }

  CIP_TASKS = [
    { name: "choose_materials", description: "Choose your training materials" },
    { name: "add_participants", description: "Add teachers and mentors", status: "on_hold" },
  ].freeze

  FIP_TASKS = [
    { name: "add_estimates", description: "Add estimated numbers of teachers and mentors" },
    { name: "add_provider", description: "Sign up with a training provider" },
    { name: "accept_legals", description: "Read and accept privacy and data policy" },
    { name: "add_participants", description: "Add teachers and mentors", status: "on_hold" },
  ].freeze

  after_create do |school_cohort|
    cohort_tasks = school_cohort.full_induction_programme? ? FIP_TASKS : CIP_TASKS
    school_cohort.tasks.create!(cohort_tasks)
  end

  belongs_to :cohort
  belongs_to :school

  has_many :tasks

  def number_of_participants_status
    tasks.find_by(name: "add_estimates")&.status_for_database
  end

  def training_provider_status
    tasks.find_by(name: "add_provider")&.status_for_database
  end

  def accept_legal_status
    tasks.find_by(name: "accept_legals")&.status_for_database
  end

  def add_participants_status
    tasks.find_by(name: "add_participants")&.status_for_database
  end

  def choose_training_materials_status
    tasks.find_by(name: "choose_materials")&.status_for_database
  end

  def status
    tasks.where.not(status: :done).none? ? "setup complete" : "to do"
  end
end
