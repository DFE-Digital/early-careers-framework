# frozen_string_literal: true

module AppropriateBodies
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :induction_record

      delegate :teacher_profile,
               :role,
               to: :participant_profile,
               allow_nil: true

      delegate :full_name,
               to: :user,
               allow_nil: true

      delegate :participant_profile,
               :training_status,
               :school,
               :user,
               :cohort,
               :lead_provider_name,
               :delivery_partner_name,
               to: :induction_record,
               allow_nil: true

      def initialize(induction_record:)
        @induction_record = induction_record
      end

      def status_tag
        return unless status_name

        title = t("participant_profile_status.status.#{status_name}.title")
        description = t("participant_profile_status.status.#{status_name}.description")

        if description.present?
          tag.strong(title) +
            tag.p(description, class: "govuk-body-s")
        else
          tag.strong(title)
        end
      end

      def email
        induction_record.preferred_identity&.email || user.email
      end

    private

      attr_reader :induction_record

      def status_name
        @status_name ||= ParticipantProfileStatus.new(
          participant_profile:,
          induction_record:,
        ).status_name
      end
    end
  end
end
