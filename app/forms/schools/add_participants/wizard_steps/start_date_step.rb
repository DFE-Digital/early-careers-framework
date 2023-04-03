# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class StartDateStep < ::WizardStep
        attr_accessor :start_date

        validate :start_date_is_present_and_correct

        def self.permitted_params
          %i[
            start_date
          ]
        end

        def next_step
          if start_date_is_out_of_registration_scope?
            :cannot_add_registration_not_yet_open
          elsif wizard.needs_to_choose_a_mentor?
            :choose_mentor
          elsif wizard.needs_to_confirm_appropriate_body?
            :confirm_appropriate_body
          else
            :check_answers
          end
        end

        def previous_step
          :email
        end

      private

        def start_date_is_out_of_registration_scope?
          # This could be dynamic based on Cohort.registration_start_date but the ask on the ticket is for
          # a temporary stop to prevent registrations
          wizard.ect_participant? && start_date >= Date.new(2023, 9, 1)
        end

        def start_date_is_present_and_correct
          if start_date.blank?
            errors.add(:start_date, :blank)
          else
            begin
              @start_date = Date.parse (1..3).map { |n| start_date[n] }.join("/")

              unless start_date.between?(Date.new(2021, 9, 1), Date.current + 1.year)
                errors.add(:start_date, :invalid)
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
