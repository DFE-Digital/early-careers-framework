# frozen_string_literal: true

module Admin
  module Participants
    class Details < BaseComponent
      def initialize(profile:)
        @profile = profile
      end

      delegate :user, :pending?, :school, :school_urn, :npq_application, :updated_at, to: :profile
      delegate :full_name, :email, to: :user

      def school_name
        return if school.blank?

        school.name
      end

      def trn
        npq_application&.teacher_reference_number
      end

      def date_of_birth
        npq_application&.date_of_birth&.to_formatted_s(:govuk)
      end

      def lead_provider_name
        npq_application&.npq_lead_provider&.name
      end

      def npq_course_name
        npq_application&.npq_course&.name
      end

      def ni_number
        npq_application&.nino
      end

      def last_updated
        updated_at.to_formatted_s(:govuk)
      end

    private

      attr_reader :profile

      class NPQPending < Details; end

      class NPQ < Details; end
    end
  end
end
