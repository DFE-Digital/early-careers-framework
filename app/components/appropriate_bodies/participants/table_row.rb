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

      def initialize(induction_record:, appropriate_body:)
        @induction_record = induction_record
        @appropriate_body = appropriate_body
      end

      def email
        induction_record.preferred_identity&.email || user.email
      end

    private

      attr_reader :induction_record
    end
  end
end
