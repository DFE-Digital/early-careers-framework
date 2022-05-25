# frozen_string_literal: true

class ChangesOfCircumstanceScenario
  attr_reader :number,
              :participant_type,
              :participant_email,
              :participant_trn,
              :participant_dob,
              :original_programme,
              :new_programme,
              :transfer,
              :withdrawn_by,
              :new_lead_provider_name,
              :prior_declarations,
              :new_declarations,
              :duplicate_declarations,
              :all_declarations,
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

  def initialize(num, fixture_data)
    scenario = fixture_data.to_h.with_indifferent_access.freeze

    @number = num
    @participant_email = "the-participant-#{num}@example.com"
    @participant_trn = rand(1..9_999_999).to_s.rjust(7, "0")
    @participant_dob = Date.new(1972, 2, 10)
    @participant_type = (scenario[:participant_type] || "").to_s
    @original_programme = (scenario[:original_programme] || "").to_s
    @new_programme = (scenario[:new_programme] || "").to_s

    @transfer = (scenario[:transfer] || "not_applicable").to_sym
    @withdrawn_by = (scenario[:withdrawn_by] || "not_applicable").to_sym

    @new_lead_provider_name = @transfer == :same_provider ? "Original Lead Provider" : "New Lead Provider"

    @prior_declarations = (scenario[:prior_declarations] || "").split(",").map(&:to_sym)
    @new_declarations = (scenario[:new_declarations] || "").split(",").map(&:to_sym)
    @duplicate_declarations = (scenario[:duplicate_declarations] || "").split(",").map(&:to_sym)
    @all_declarations = @prior_declarations + @new_declarations

    @starting_school_status = (scenario[:starting_school_status] || "not_applicable").to_sym

    @prior_school_status = (scenario[:prior_school_status] || "not_applicable").to_sym
    @prior_participant_status = (scenario[:prior_participant_status] || "not_applicable").to_sym
    @prior_training_status = (scenario[:prior_training_status] || "not_applicable").to_sym

    @new_school_status = (scenario[:new_school_status] || "not_applicable").to_sym
    @new_participant_status = (scenario[:new_participant_status] || "not_applicable").to_sym
    @new_training_status = (scenario[:new_training_status] || "not_applicable").to_sym

    @see_original_details = (scenario[:see_original_details] || "not_applicable").to_sym
    @see_original_declarations = (scenario[:see_original_declarations] || "").split(",").map(&:to_sym)

    @see_new_details = (scenario[:see_new_details] || "not_applicable").to_sym
    @see_new_declarations = (scenario[:see_new_declarations] || "").split(",").map(&:to_sym)

    @original_payment_ects = (scenario[:original_payment_ects] || "0").to_i
    @original_payment_mentors = (scenario[:original_payment_mentors] || "0").to_i
    @original_payment_declarations = (scenario[:original_payment_declarations] || "0").to_i

    @new_payment_ects = (scenario[:new_payment_ects] || "0").to_i
    @new_payment_mentors = (scenario[:new_payment_mentors] || "0").to_i
    @new_payment_declarations = (scenario[:new_payment_declarations] || "0").to_i
  end
end
