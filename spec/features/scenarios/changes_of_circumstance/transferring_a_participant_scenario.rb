# frozen_string_literal: true

class TransferringParticipantScenario
  attr_reader :number,
              :participant_type,
              :original_programme,
              :new_programme,
              :transfer,
              :prior_declarations,
              :new_declarations,
              :duplicate_declarations,
              :starting_school_status,
              :prior_school_status,
              :new_school_status,
              :prior_participant_status,
              :new_participant_status,
              :prior_training_status,
              :new_training_status,
              :see_original_details,
              :see_new_details,
              :see_original_declarations,
              :see_new_declarations,
              :original_payment_ects,
              :original_payment_mentors,
              :original_payment_declarations,
              :new_payment_ects,
              :new_payment_mentors,
              :new_payment_declarations

  def initialize(num, hash)
    scenario = hash.with_indifferent_access.freeze

    @number = num
    @participant_type = scenario.fetch(:participant_type)
    @original_programme = scenario.fetch(:original_programme)
    @new_programme = scenario.fetch(:new_programme)

    @transfer = scenario.fetch(:transfer, :not_applicable)

    @prior_declarations = scenario.fetch(:prior_declarations, "").split(",").map(&:to_sym)
    @new_declarations = scenario.fetch(:new_declarations, "").split(",").map(&:to_sym)
    @duplicate_declarations = scenario.fetch(:duplicate_declarations, "").split(",").map(&:to_sym)

    @starting_school_status = scenario.fetch(:starting_school_status, :not_applicable)
    @prior_school_status = scenario.fetch(:prior_school_status, :not_applicable)
    @new_school_status = scenario.fetch(:new_school_status, :not_applicable)
    @prior_participant_status = scenario.fetch(:prior_participant_status, :not_applicable)
    @new_participant_status = scenario.fetch(:new_participant_status, :not_applicable)
    @prior_training_status = scenario.fetch(:prior_training_status, :not_applicable)
    @new_training_status = scenario.fetch(:new_training_status, :not_applicable)

    @see_original_details = scenario.fetch(:see_original_details, :not_applicable)
    @see_new_details = scenario.fetch(:see_new_details, :not_applicable)
    @see_original_declarations = scenario.fetch(:see_original_declarations, :not_applicable)
    @see_new_declarations = scenario.fetch(:see_new_declarations, :not_applicable)

    @original_payment_ects = scenario.fetch(:original_payment_ects, 0)
    @original_payment_mentors = scenario.fetch(:original_payment_mentors, 0)
    @original_payment_declarations = scenario.fetch(:original_payment_declarations, 0)
    @new_payment_ects = scenario.fetch(:new_payment_ects, 0)
    @new_payment_mentors = scenario.fetch(:new_payment_mentors, 0)
    @new_payment_declarations = scenario.fetch(:new_payment_declarations, 0)
  end
end
