# frozen_string_literal: true

module Schools
  class SetupSchoolCohortForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serialization

    attr_accessor :expect_any_ects_choice, :how_will_you_run_training_choice

    validates :expect_any_ects_choice, presence: true, on: :expect_any_ects
    validates :how_will_you_run_training_choice, presence: true, on: :how_will_you_run_training

    def attributes
      {
        expect_any_ects_choice: expect_any_ects_choice,
        how_will_you_run_training_choice: how_will_you_run_training_choice,
      }
    end

    def expect_any_ects_choices
      [
        OpenStruct.new(id: "yes", name: "Yes"),
        OpenStruct.new(id: "no", name: "No"),
      ]
    end

    def how_will_you_run_training_choices
      [
        OpenStruct.new(id: "full_induction_programme", name: "Use a training provider, funded by the DfE"),
        OpenStruct.new(id: "core_induction_programme", name: "Deliver your own programme using DfE-accredited materials"),
        OpenStruct.new(id: "design_our_own", name: "Design and deliver you own programme based on the early career framework (ECF)"),
      ]
    end

    def using_schools_programme?
      same_programme || switch_to_schools_programme?
    end

    def switch_to_schools_programme?
      schools_current_programme_choice == "yes" && !continue_teachers_programme?
    end

    def continue_teachers_programme?
      teachers_current_programme_choice == "yes"
    end

    def mentor
      User.find(mentor_id) if mentor_id.present?
    end

    def mentor_profile
      mentor&.mentor_profile
    end

  private

    def teacher_start_date
      @start_date = ActiveRecord::Type::Date.new.cast(start_date)
      if @start_date.blank?
        errors.add(:start_date, I18n.t("errors.start_date.blank"))
      elsif @start_date.year.digits.length != 4
        errors.add(:start_date, I18n.t("errors.start_date.invalid"))
      end
    end

    def dob
      @date_of_birth = ActiveRecord::Type::Date.new.cast(date_of_birth)
      if date_of_birth.blank?
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.blank"))
      elsif date_of_birth > Time.zone.now
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.in_future"))
      elsif !date_of_birth.between?(Date.new(1900, 1, 1), Date.current - 18.years)
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.invalid"))
      elsif date_of_birth.year.digits.length != 4
        errors.add(:date_of_birth, I18n.t("errors.date_of_birth.invalid"))
      end
    end

    def schools_programme_choice
      errors.add(:schools_current_programme_choice, :blank) unless schools_current_programme_choices.map(&:id).include?(schools_current_programme_choice)
    end

    def teachers_programme_choice
      errors.add(:teachers_current_programme_choice, :blank) unless teachers_current_programme_choices.map(&:id).include?(teachers_current_programme_choice)
    end

    def check_mentor
      @mentor_id = nil if mentor_id == "later"
    end
  end
end
