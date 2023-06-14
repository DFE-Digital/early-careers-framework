# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      class ChangeRelationshipWizard < Wizard::Form
        delegate :reason_for_change_mistake?, :reason_for_change_circumstances?,
                 to: :data_store

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

        def induction_record
          @induction_record ||= Induction::FindBy.call(participant_profile:)
        end

        def current_partnership
          induction_record.induction_programme.partnership
        end

        def school_default_partnership
          school_partnerships.find_by(relationship: false)
        end

        def school_partnerships
          induction_record.school.active_partnerships.in_year(induction_record.cohort.start_year).order(relationship: :asc)
        end

        def abort_path
          if participant_profile.present?
            admin_participant_path(participant_id: participant_profile)
          else
            admin_participants_path
          end
        end

        def participant_name
          @participant_name ||= participant_profile.user.full_name
        end

        def participant_role_and_name
          "#{participant_profile.role} - #{participant_name}"
        end

        def programme_can_be_changed?
          # determine whether the programme can be changed for the participant in this journey
          true
        end

        def show_path_for(step:)
          show_admin_change_relationship_participant_path(**path_options(step:))
        end

        def change_path_for(step:)
          show_change_admin_change_relationship_participant_path(**path_options(step:))
        end

        def path_options(step: nil)
          path_opts = {
            id: participant_profile.id,
          }

          path_opts[:step] = step.to_s.dasherize if step.present?
          path_opts
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
