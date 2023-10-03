# frozen_string_literal: true

module Admin
  module Participants
    class ValidationPreview
      class << self
        def call(participant_profile)
          new(participant_profile:).tap(&:call)
        end
      end

      attr_reader :validation_data, :dqt_response, :new_validation_state, :participant_presenter

      def initialize(participant_profile:)
        @participant_profile = participant_profile
        @validation_data = {}
        @dqt_response = {}
        @new_validation_state = nil
        @participant_presenter = nil
        @revalidating = Admin::ParticipantPresenter.new(@participant_profile).eligibility_data.present?
      end

      def call
        ActiveRecord::Base.transaction do
          @participant_profile.teacher_profile.update!(trn: nil) unless @participant_profile.teacher_profile.npq_profiles.any?
          @participant_profile.ecf_participant_eligibility&.destroy!
          # this returns either nil, false on failure or an ECFParticipantEligibility record on success
          @validation_form = ::Participants::ParticipantValidationForm.build(@participant_profile)

          @validation_data = {
            trn: @validation_form.formatted_trn,
            nino: @validation_form.nino,
            full_name: @validation_form.full_name,
            dob: @validation_form.dob,
          }

          @validation_form.call

          @dqt_response = @validation_form.dqt_response

          record_state = DetermineTrainingRecordState.call(participant_profile: @participant_profile)
          @new_validation_state = record_state.validation_state

          @participant_presenter = Admin::ParticipantPresenter.new(@participant_profile)

          raise ActiveRecord::Rollback
        end
      end

      def revalidating?
        @revalidating
      end
    end
  end
end
