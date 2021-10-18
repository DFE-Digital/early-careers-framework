# frozen_string_literal: true

module Participants
  class ParticipantValidationForm
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Model

    # lifted from https://github.com/dwp/nino-format-validation
    NINO_REGEX = /(^(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-Z&&[^DFIQUV]][A-Z&&[^DFIOQUV]][0-9]{6}[A-D]$)/.freeze
    attr_accessor :step,
                  :do_you_want_to_add_mentor_information_choice,
                  :trn,
                  :name,
                  :national_insurance_number,
                  :validation_attempts,
                  # legacy values kept here to prevent breakages with old sessions
                  :do_you_know_your_trn_choice,
                  :have_you_changed_your_name_choice,
                  :updated_record_choice,
                  :name_not_updated_choice

    attr_reader :date_of_birth

    validate :add_mentor_info_choice, on: :do_you_want_to_add_mentor_information
    validate :trn_entry, on: :what_is_your_trn
    validate :teacher_details, on: :tell_us_your_details

    def attributes
      {
        step: step,
        do_you_want_to_add_mentor_information_choice: do_you_want_to_add_mentor_information_choice,
        trn: trn&.squish,
        name: name&.squish,
        date_of_birth: date_of_birth,
        national_insurance_number: tidy_national_insurance_number,
        validation_attempts: validation_attempts.to_i, # coerce nil to 0
      }
    end

    def date_of_birth=(value)
      @date_of_birth_invalid = false
      @date_of_birth = ActiveRecord::Type::Date.new.cast(value)

      if invalid_date?(value)
        @date_of_birth_invalid = true
        @date_of_birth = value
      end
    rescue StandardError
      @date_of_birth_invalid = true
    end

    def add_mentor_information_choices
      [
        OpenStruct.new(id: "yes", name: "Yes, I want to add information now"),
        OpenStruct.new(id: "no", name: "No, I’ll do it later"),
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

    def add_mentor_info_choice
      errors.add(:do_you_want_to_add_mentor_information_choice, :blank) unless add_mentor_information_choices.map(&:id).include?(do_you_want_to_add_mentor_information_choice)
    end

    def trn_entry
      @trn = trn&.squish

      if trn.blank?
        errors.add(:trn, :blank)
      else
        @trn = trn.gsub(/RP/, "").gsub(/[\/\s]/, "")

        if trn !~ /\A\d+\z/
          errors.add(:trn, :invalid)
        elsif trn.length < 5
          errors.add(:trn, :too_short, count: 5)
        elsif trn.length > 7
          errors.add(:trn, :too_long, count: 7)
        end
      end
    end

    def teacher_details
      @name = name&.squish
      @national_insurance_number = tidy_national_insurance_number

      if name.blank?
        errors.add(:name, :blank)
      end

      if @date_of_birth_invalid
        errors.add(:date_of_birth, :invalid)
      elsif date_of_birth.blank?
        errors.add(:date_of_birth, :blank)
      elsif date_of_birth > Time.zone.now
        errors.add(:date_of_birth, :in_the_future)
      elsif date_of_birth.year.digits.length != 4
        errors.add(:date_of_birth, :invalid_year)
      end

      if national_insurance_number.present? && national_insurance_number !~ NINO_REGEX
        errors.add(:national_insurance_number, :invalid)
      end
    end

    def tidy_national_insurance_number
      return if national_insurance_number.blank?

      national_insurance_number.gsub(/\s+/, "").upcase
    end

    def invalid_date?(value)
      return if value.blank?

      day = value[3]
      month = value[2]
      year = value[1]
      !Date.valid_date?(year, month, day)
    end
  end
end
