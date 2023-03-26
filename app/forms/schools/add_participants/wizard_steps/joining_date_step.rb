# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class JoiningDateStep < ::WizardStep
        attr_accessor :start_date

        validate :start_date_is_present_and_correct

        def self.permitted_params
          %i[
            start_date
          ]
        end

        def next_step
          :email
          # if wizard.needs_to_choose_a_mentor?
          #   :choose_mentor
          # elsif wizard.needs_to_confirm_appropriate_body?
          #   :confirm_appropriate_body
          # else
          #   :check_answers
          # end
        end

        def previous_step
          # this is the previous "who-to-add" journey
          :confirm_transfer
        end

      private

        def start_date_is_present_and_correct
          if start_date.blank?
            errors.add(:start_date, :blank)
          else
            begin
              @start_date = Date.parse (1..3).map { |n| start_date[n] }.join("/")

              if start_date > Date.current + 1.year
                errors.add(:start_date, :invalid)
              elsif start_date < wizard.existing_induction_start_date
                errors.add(:start_date, I18n.t("errors.start_date.before_schedule_start_date", date: wizard.existing_induction_start_date.to_date.to_s(:govuk)))
              end
            rescue Date::Error
              errors.add(:start_date, :invalid)
              nil
            end
          end
        end
      end
    end
  end
end
