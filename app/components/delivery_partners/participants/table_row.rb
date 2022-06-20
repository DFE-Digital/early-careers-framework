# frozen_string_literal: true

module DeliveryPartners
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :participant_profile

      delegate :user,
               :teacher_profile,
               :cohort,
               to: :participant_profile

      delegate :full_name, :user_description,
               to: :user

      delegate :training_status,
               :school,
               to: :induction_record,
               allow_nil: true

      def initialize(participant_profile:, delivery_partner:)
        @participant_profile = participant_profile
        @delivery_partner = delivery_partner
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

      def email
        induction_record&.preferred_identity&.email || user.email
      end

    private

      attr_reader :participant_profile, :delivery_partner

      def induction_record
        @induction_record ||= participant_profile.induction_records.includes(induction_programme: [:partnership]).where(
          induction_programme: {
            partnerships: {
              delivery_partner:,
              challenged_at: nil,
              challenge_reason: nil,
              pending: false,
            },
          },
        ).latest
      end

      def status_name
        @status_name ||= DeliveryPartners::ParticipantProfileStatus.new(
          participant_profile:,
        ).status_name
      end
    end
  end
end
