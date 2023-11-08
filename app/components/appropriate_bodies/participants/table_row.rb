# frozen_string_literal: true

module AppropriateBodies
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :induction_record

      delegate :teacher_profile,
               to: :participant_profile,
               allow_nil: true

      delegate :full_name,
               to: :user,
               allow_nil: true

      delegate :participant_profile,
               :school,
               :user,
               to: :induction_record,
               allow_nil: true

      def initialize(induction_record:, training_record_states:)
        @induction_record = induction_record
        @training_record_states = training_record_states
      end

      def induction_type
        if induction_record.enrolled_in_cip?
          "CIP"
        elsif induction_record.enrolled_in_fip?
          "FIP"
        end
      end

      def induction_tutor
        school.contact_email
      end

    private

      attr_reader :induction_record, :training_record_states
    end
  end
end
