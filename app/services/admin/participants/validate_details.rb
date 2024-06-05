# frozen_string_literal: true

module Admin
  module Participants
    class ValidateDetails
      class << self
        def call(participant_profile)
          new(participant_profile:).call
        end

        def preview(participant_profile)
          new(participant_profile:).preview
        end
      end

      PreviewStruct = Struct.new(
        :validation_data,
        :dqt_response,
        :new_validation_state,
        :eligibility_data,
        :revalidating,
        keyword_init: true,
      )

      attr_reader :dqt_response, :new_validation_state, :participant_presenter

      def initialize(participant_profile:)
        @participant_profile = participant_profile
        @preview_response = nil
        @revalidating = Admin::ParticipantPresenter.new(@participant_profile).eligibility_data.present?
      end

      def call
        return unless validation_data_permits_validation?

        ActiveRecord::Base.transaction do
          @previously_eligible = @participant_profile.eligible?
          @participant_profile.teacher_profile.update!(trn: nil) unless has_npq_profile?
          @participant_profile.ecf_participant_eligibility&.destroy!
          # this returns either nil, false on failure or an ECFParticipantEligibility record on success
          @validation_form = build_validation_form
          run_validation
        end
      end

      def preview
        return unless validation_data_permits_validation?

        ActiveRecord::Base.transaction do
          call

          # We have to use this instead of @participant_profile because the form itself reloads the record from scratch
          preview_profile = @validation_form.participant_profile

          # We are using as_json here rather than the presenter because we want to have the data
          # as it was before the transaction was rolled back, if we use the presenter it will
          # have the data as it is after the transaction was rolled back and so not show us a true preview.
          # This applies for all the data in the preview response.
          eligibility_data = Admin::ParticipantPresenter.new(preview_profile).eligibility_data.as_json

          new_validation_state = DetermineTrainingRecordStateLegacy.call(participant_profile: preview_profile)
                                                             .validation_state

          @preview_response = PreviewStruct.new(
            validation_data: {
              trn: @validation_form.formatted_trn,
              nino: @validation_form.nino,
              full_name: @validation_form.full_name,
              dob: @validation_form.dob,
            },
            dqt_response: @validation_form.dqt_response,
            new_validation_state:,
            eligibility_data:,
            revalidating: @revalidating,
          )

          raise ActiveRecord::Rollback
        end

        @preview_response
      end

    private

      def validation_data
        @validation_data ||= @participant_profile.ecf_participant_validation_data || ECFParticipantValidationData.new(participant_profile: @participant_profile)
      end

      def validation_data_permits_validation?
        validation_data.present? && validation_data.can_validate_participant?
      end

      def has_npq_profile?
        @participant_profile.teacher_profile.npq_profiles.any?
      end

      def clear_existing_validation_data
        @participant_profile.teacher_profile.update!(trn: nil) unless has_npq_profile?
        @participant_profile.ecf_participant_eligibility&.destroy!
      end

      def build_validation_form
        ::Participants::ParticipantValidationForm.build(@participant_profile)
      end

      def run_validation
        # this returns either nil, false on failure or an ECFParticipantEligibility record on success
        @validation_form.call.tap do
          if !@previously_eligible &&
              Induction::AmendCohortAfterEligibilityChecks.new(participant_profile: @participant_profile.reload).call
            return true
          end
        end
      end
    end
  end
end
