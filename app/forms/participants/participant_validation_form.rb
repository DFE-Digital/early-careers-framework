# frozen_string_literal: true

module Participants
  class ParticipantValidationForm
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Model

    # lifted from https://github.com/dwp/nino-format-validation
    NINO_REGEX = /(^(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-Z&&[^DFIQUV]][A-Z&&[^DFIOQUV]][0-9]{6}[A-D]$)/.freeze
    attr_accessor :step
    attr_accessor :do_you_know_your_trn_choice, :have_you_changed_your_name_choice
    attr_accessor :updated_record_choice, :name_not_updated_choice
    attr_accessor :trn, :name, :national_insurance_number
    attr_reader :date_of_birth
    attr_accessor :validation_attempts

    validate :trn_choice, on: :do_you_know_your_trn
    validate :name_change_choice, on: :have_you_changed_your_name
    validate :confirm_updated_record_choice, on: :confirm_updated_record
    validate :confirm_name_not_updated_choice, on: :name_not_updated
    validate :teacher_details, on: :tell_us_your_details

    def attributes
      {
        step: step,
        do_you_know_your_trn_choice: do_you_know_your_trn_choice,
        have_you_changed_your_name_choice: have_you_changed_your_name_choice,
        updated_record_choice: updated_record_choice,
        name_not_updated_choice: name_not_updated_choice,
        trn: trn&.squish,
        name: name&.squish,
        date_of_birth: date_of_birth,
        national_insurance_number: national_insurance_number&.squish,
        validation_attempts: validation_attempts.to_i, # coerce nil to 0
      }
    end

    def date_of_birth=(value)
      @date_of_birth_invalid = false
      @date_of_birth = ActiveRecord::Type::Date.new.cast(value)
    rescue StandardError
      @date_of_birth_invalid = true
    end

    def trn_choices
      [
        OpenStruct.new(id: "yes", name: "Yes, I know my TRN"),
        OpenStruct.new(id: "no", name: "No, I do not know my TRN"),
        OpenStruct.new(id: "i_do_not_have", name: "I do not have a TRN"),
      ]
    end

    def name_change_choices
      [
        OpenStruct.new(id: "yes", name: "Yes, I changed my name"),
        OpenStruct.new(id: "no", name: "No, I have the same name"),
      ]
    end

    def updated_record_choices
      [
        OpenStruct.new(id: "yes", name: "Yes, my name has been updated"),
        OpenStruct.new(id: "no", name: "No, I need to update my name"),
        OpenStruct.new(id: "i_do_not_know", name: "I’m not sure"),
      ]
    end

    def name_not_updated_choices
      [
        OpenStruct.new(id: "register_previous_name", name: "Register for this programme using your previous name (you can update this later)"),
        OpenStruct.new(id: "update_name", name: "Update your name with the Teaching Regulation Agency"),
      ]
    end

    def pretty_date_of_birth
      if date_of_birth.present?
        date_of_birth.to_s(:govuk)
      end
    end

    def increment_validation_attempts
      if validation_attempts.nil?
        @validation_attempts = 1
      else
        @validation_attempts += 1
      end
    end

  private

    def trn_choice
      errors.add(:do_you_know_your_trn_choice, :blank) unless trn_choices.map(&:id).include?(do_you_know_your_trn_choice)
    end

    def name_change_choice
      errors.add(:have_you_changed_your_name_choice, :blank) unless name_change_choices.map(&:id).include?(have_you_changed_your_name_choice)
    end

    def confirm_updated_record_choice
      errors.add(:updated_record_choice, :blank) unless updated_record_choices.map(&:id).include?(updated_record_choice)
    end

    def confirm_name_not_updated_choice
      errors.add(:name_not_updated_choice, :blank) unless name_not_updated_choices.map(&:id).include?(name_not_updated_choice)
    end

    def teacher_details
      if trn.blank?
        errors.add(:trn, :blank)
      elsif trn.length < 5
        errors.add(:trn, :too_short, count: 5)
      elsif trn.length > 7
        errors.add(:trn, :too_long, count: 7)
      elsif trn !~ /\A\d+\z/
        errors.add(:trn, :invalid)
      end

      if name.blank?
        errors.add(:name, :blank)
      end

      if @date_of_birth_invalid
        errors.add(:date_of_birth, :invalid)
      elsif date_of_birth.blank?
        errors.add(:date_of_birth, :blank)
      elsif date_of_birth > Time.zone.now
        errors.add(:date_of_birth, :in_the_future)
      end

      if national_insurance_number.present? && national_insurance_number.squish !~ NINO_REGEX
        errors.add(:national_insurance_number, :invalid)
      end
    end
  end
end
