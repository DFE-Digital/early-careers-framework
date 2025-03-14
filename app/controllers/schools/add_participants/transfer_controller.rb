# frozen_string_literal: true

module Schools
  module AddParticipants
    class TransferController < BaseController
      before_action :initialize_wizard
      before_action :data_check

      def update
        if @form.valid?
          @wizard.save!
          needs_user_dedup_sign_in?
          redirect_to @wizard.next_step_path
        else
          track_validation_error(@form)
          render @wizard.current_step
        end
      end

    private

      def needs_user_dedup_sign_in?
        if @wizard.after_user_dedup_sign_in_needed
          if true_user.admin?
            impersonate_user(@wizard.current_user)
          else
            sign_in(@wizard.current_user, scope: :user)
          end
          ensure_policy_acceptance
        end
      end

      def ensure_policy_acceptance
        policy = PrivacyPolicy.current
        if policy.acceptance_required?(@wizard.current_user)
          policy.accept!(@wizard.current_user)
        end
      end

      def data_check
        if has_already_completed? || !who_stage_complete?
          Rails.logger.info("TransferController#data_check: check failed {has_already_completed? = #{has_already_completed?}, found_participant_in_dqt? = #{@wizard.found_participant_in_dqt?}, transfer? = #{@wizard.transfer?}")
          remove_session_data
          redirect_to abort_path
        end
      end

      def wizard_class
        TransferWizard
      end

      def default_step_name
        "joining-date"
      end

      def has_already_completed?
        @wizard.complete? && step_name.to_sym != :complete
      end

      def who_stage_complete?
        @wizard.found_participant_in_dqt? && @wizard.transfer?
      end
    end
  end
end
