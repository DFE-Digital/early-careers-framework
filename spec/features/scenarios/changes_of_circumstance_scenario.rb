# frozen_string_literal: true

class ChangesOfCircumstanceScenario
  attr_reader :number,
              :statement_name,
              :participant_type,
              :participant_email,
              :participant_trn,
              :participant_dob,
              :original_programme,
              :new_programme,
              :new_lead_provider_name,
              :transfer,
              :prior_declarations,
              :duplicate_declarations,
              :new_declarations,
              :all_declarations,
              :see_original_declarations,
              :see_new_declarations,
              :original_payment_ects,
              :original_payment_mentors,
              :original_started_declarations,
              :original_retained_declarations,
              :new_payment_ects,
              :new_payment_mentors,
              :new_started_declarations,
              :new_retained_declarations

  def initialize(num, fixture_data, academic_year = 2021)
    scenario = fixture_data.to_h.with_indifferent_access.freeze

    @number = num
    @statement_name = "November #{academic_year}"
    @participant_email = "the-participant-#{num}@example.com"
    @participant_trn = rand(1..9_999_999).to_s.rjust(7, "0")
    @participant_dob = Date.new(1972, 2, 10)
    @participant_type = (scenario[:participant_type] || "").to_s
    @original_programme = (scenario[:original_programme] || "").to_s
    @new_programme = (scenario[:new_programme] || "").to_s

    @transfer = (scenario[:transfer] || "not_applicable").to_sym

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

    if @transfer == :not_applicable && @original_programme == "FIP"
      @original_started_declarations = @prior_declarations.filter { |sym| sym == :started }.count
      @original_retained_declarations = @prior_declarations.filter { |sym| sym == :retained_1 }.count
      @original_payment_ects = @participant_type == "ECT" && @prior_declarations.any? ? 1 : 0
      @original_payment_mentors = @participant_type == "Mentor" && @prior_declarations.any? ? 1 : 0

      @see_original_declarations = @prior_declarations
    elsif @transfer == :not_applicable && @new_programme == "FIP"
      @new_payment_ects = @participant_type == "ECT" && @new_declarations.any? ? 1 : 0
      @new_payment_mentors = @participant_type == "Mentor" && @new_declarations.any? ? 1 : 0
      @new_started_declarations = @new_declarations.filter { |sym| sym == :started }.count
      @new_retained_declarations = @new_declarations.filter { |sym| sym == :retained_1 }.count

      @see_new_declarations = @new_declarations
    elsif @transfer == :same_provider
      @original_started_declarations = @all_declarations.filter { |sym| sym == :started }.count
      @original_retained_declarations = @all_declarations.filter { |sym| sym == :retained_1 }.count
      @original_payment_ects = @participant_type == "ECT" && @all_declarations.any? ? 1 : 0
      @original_payment_mentors = @participant_type == "Mentor" && @all_declarations.any? ? 1 : 0

      @see_original_declarations = @all_declarations
    elsif @transfer == :different_provider
      @original_started_declarations = @prior_declarations.filter { |sym| sym == :started }.count
      @original_retained_declarations = @prior_declarations.filter { |sym| sym == :retained_1 }.count
      @original_payment_ects = @participant_type == "ECT" && @prior_declarations.any? ? 1 : 0
      @original_payment_mentors = @participant_type == "Mentor" && @prior_declarations.any? ? 1 : 0

      @see_original_declarations = @prior_declarations

      @new_payment_ects = @participant_type == "ECT" && @new_declarations.any? ? 1 : 0
      @new_payment_mentors = @participant_type == "Mentor" && @new_declarations.any? ? 1 : 0
      @new_started_declarations = @new_declarations.filter { |sym| sym == :started }.count
      @new_retained_declarations = @new_declarations.filter { |sym| sym == :retained_1 }.count

      @see_new_declarations = @all_declarations
    end
  end
end
