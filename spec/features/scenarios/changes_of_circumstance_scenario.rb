# frozen_string_literal: true

class ChangesOfCircumstanceScenario
  attr_reader :number,
              :participant_type,
              :participant_email,
              :participant_trn,
              :participant_dob,
              :original_programme,
              :starting_school_status,
              :new_programme,
              :new_lead_provider_name,
              :transfer,
              :withdrawn_by,
              :prior_declarations,
              :duplicate_declarations,
              :new_declarations,
              :all_declarations,
              :see_original_details,
              :see_original_declarations,
              :see_new_details,
              :see_new_declarations,
              :original_payment_ects,
              :original_payment_mentors,
              :original_started_declarations,
              :original_retained_declarations,
              :new_payment_ects,
              :new_payment_mentors,
              :new_started_declarations,
              :new_retained_declarations

  def initialize(num, fixture_data)
    scenario = fixture_data.to_h.with_indifferent_access.freeze

    @number = num
    @participant_email = "the-participant-#{num}@example.com"
    @participant_trn = rand(1..9_999_999).to_s.rjust(7, "0")
    @participant_dob = {
      year: "1972",
      month: "02",
      day: "10",
    }
    @participant_type = (scenario[:participant_type] || "").to_s
    @original_programme = (scenario[:original_programme] || "").to_s
    @new_programme = (scenario[:new_programme] || "").to_s

    @transfer = (scenario[:transfer] || "not_applicable").to_sym
    @withdrawn_by = (scenario[:withdrawn_by] || "not_applicable").to_sym

    @new_lead_provider_name = if @new_programme == "CIP"
                                ""
                              elsif @transfer == :same_provider
                                "Original Lead Provider"
                              else
                                "New Lead Provider"
                              end

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
    @original_started_declarations = @prior_declarations.filter { |sym| sym == :started }.count
    @original_retained_declarations = @prior_declarations.filter { |sym| sym == :retained_1 }.count

    @new_payment_ects = (scenario[:new_payment_ects] || "0").to_i
    @new_payment_mentors = (scenario[:new_payment_mentors] || "0").to_i
    @new_started_declarations = @new_declarations.filter { |sym| sym == :started }.count
    @new_retained_declarations = @new_declarations.filter { |sym| sym == :retained_1 }.count
  end
end
