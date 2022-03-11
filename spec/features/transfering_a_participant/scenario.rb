# frozen_string_literal: true

class Scenario
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
              :see_new_declarations

  def initialize(num, hash)
    scenario = OpenStruct.new(hash)

    @number = num
    @participant_type = scenario.participant_type
    @original_programme = scenario.original_programme
    @new_programme = scenario.new_programme

    @transfer = to_sym_or_default scenario.transfer, :not_applicable

    @prior_declarations = (scenario.prior_declarations || "").split(",").map(&:to_sym)
    @new_declarations = (scenario.new_declarations || "").split(",").map(&:to_sym)
    @duplicate_declarations = (scenario.duplicate_declarations || "").split(",").map(&:to_sym)

    @starting_school_status = to_sym_or_default scenario.starting_school_status, :not_applicable
    @prior_school_status = to_sym_or_default scenario.prior_school_status, :not_applicable
    @new_school_status = to_sym_or_default scenario.new_school_status, :not_applicable
    @prior_participant_status = to_sym_or_default scenario.prior_participant_status, :not_applicable
    @new_participant_status = to_sym_or_default scenario.new_participant_status, :not_applicable
    @prior_training_status = to_sym_or_default scenario.prior_training_status, :not_applicable
    @new_training_status = to_sym_or_default scenario.new_training_status, :not_applicable

    @see_original_details = to_sym_or_default scenario.see_original_details, :not_applicable
    @see_new_details = to_sym_or_default scenario.see_new_details, :not_applicable
    @see_original_declarations = to_sym_or_default scenario.see_original_declarations, :not_applicable
    @see_new_declarations = to_sym_or_default scenario.see_new_declarations, :not_applicable
  end

private

  def to_sym_or_default(str, default)
    (str || default).to_sym
  end
end
