# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class StartDateStep < ::WizardStep
      attr_accessor :start_date

      validate :start_date_is_present_and_correct

      def self.permitted_params
        %i[
          start_date
        ]
      end

      def next_step
        if wizard.ect_participant? && wizard.mentor_options.any?
          :choose_mentor
        else
          :check_answers
        end
      end

      def previous_step
        :email
      end

    private

      def start_date_is_present_and_correct
        @start_date = ActiveRecord::Type::Date.new.cast(start_date)
        if start_date.blank?
          errors.add(:start_date, I18n.t("errors.start_date.blank"))
        elsif !start_date.between?(Date.new(2021, 9, 1), Date.current + 1.year)
          errors.add(:start_date, I18n.t("errors.start_date.invalid"))
        elsif start_date.year.digits.length != 4
          errors.add(:start_date, I18n.t("errors.start_date.invalid"))
        end
      end
    end
  end
end
