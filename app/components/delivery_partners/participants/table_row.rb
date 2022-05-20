# frozen_string_literal: true

module DeliveryPartners
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :participant_profile

      delegate :user,
               :teacher_profile,
               :school,
               :cohort,
               to: :participant_profile

      delegate :full_name, :email, :user_description,
               to: :user

      delegate :training_status,
               to: :induction_record,
               allow_nil: true

      def initialize(participant_profile:)
        @participant_profile = participant_profile
      end

      def status_tag
        title = t(".status.#{status_name}.title")
        description = t(".status.#{status_name}.description")

        if description.present?
          content_tag(:strong, title) +
            content_tag(:p, description, class: "govuk-body-s")
        else
          content_tag(:strong, title)
        end
      end

      def lead_provider_name
        induction_record&.induction_programme&.partnership&.lead_provider&.name
      end

    private

      attr_reader :participant_profile

      def induction_record
        participant_profile.induction_records.active.latest
      end

      def status_name
        @status_name ||= DeliveryPartners::ParticipantProfileStatus.new(
          participant_profile: participant_profile,
        ).status_name
      end
    end
  end
end
