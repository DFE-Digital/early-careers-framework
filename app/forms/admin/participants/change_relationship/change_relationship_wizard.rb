# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      class ChangeRelationshipWizard < Wizard::Form
        def self.permitted_params_for(step)
          "Admin::Participants::ChangeRelationship::WizardSteps::#{step.to_s.camelcase}Step".constantize.permitted_params
        end

        def self.steps
          Admin::Participants::ChangeRelationship::WizardSteps
            .constants
            .select { |constant| constant.name.end_with?("Step") }
            .map { |constant| constant.name.chomp("Step").underscore.to_sym }
        end

        def after_initialize(**opts)
          store_participant_profile!(opts[:participant_profile])
        end

        def participant_profile
          @participant_profile ||= data_store.participant_profile
        end

        def abort_path
          if participant_profile.present?
            admin_participant_path(participant_id: participant_profile)
          else
            admin_participants_path
          end
        end

        def participant_role_and_name
          "#{participant_profile.role} - #{participant_profile.user.full_name}"
        end

        def i18n_text(key:, scope:)
          I18n.t(key, scope: "admin.participants.change_relationship.#{scope}")
        end

      private

        def store_participant_profile!(profile)
          if participant_profile.present? && participant_profile != profile
            raise AlreadyInitialised, "participant_profile different"
          end

          data_store.set(:participant_profile, profile)
          @participant_profile = profile
        end
      end
    end
  end
end
