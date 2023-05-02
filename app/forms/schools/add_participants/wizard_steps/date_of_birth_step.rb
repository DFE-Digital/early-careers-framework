# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class DateOfBirthStep < ::WizardStep
        include WhoToAddParticipantChecks

        attr_accessor :date_of_birth

        validate :date_of_birth_is_present_and_correct

        def self.permitted_params
          %i[
            date_of_birth
          ]
        end

        def next_step
          next_step_after_participant_check
        end

        def journey_complete?
          next_step == :none
        end

      private

        def date_of_birth_is_present_and_correct
          if date_of_birth.blank?
            errors.add(:date_of_birth, :blank)
          else
            begin
              @date_of_birth = Date.parse (1..3).map { |n| date_of_birth[n] }.join("/")

              if date_of_birth > Time.zone.now || !date_of_birth.between?(Date.new(1900, 1, 1), Date.current - 18.years)
                errors.add(:date_of_birth, :invalid)
              end
            rescue Date::Error
              errors.add(:date_of_birth, :invalid)
              nil
            end
          end
        end
      end
    end
  end
end
