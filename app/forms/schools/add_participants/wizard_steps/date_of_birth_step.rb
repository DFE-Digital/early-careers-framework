# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class DateOfBirthStep < ::WizardStep
        attr_accessor :date_of_birth

        validate :date_of_birth_is_present_and_correct

        def self.permitted_params
          %i[
            date_of_birth
          ]
        end

        def next_step
          if wizard.participant_exists?
            if wizard.already_enrolled_at_school?
              :cannot_add_already_enrolled_at_school
            elsif wizard.ect_participant?
              :confirm_transfer
            else
              :confirm_mentor_transfer
            end
          elsif wizard.dqt_record_has_different_name?
            :known_by_another_name
          elsif wizard.found_participant_in_dqt? || wizard.sit_mentor?
            :none
          else
            :cannot_find_their_details
          end
        end

        def previous_step
          :trn
        end

        def journey_complete?
          next_step == :none
        end

      private

        def date_of_birth_is_present_and_correct
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
      end
    end
  end
end
