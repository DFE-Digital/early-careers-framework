# frozen_string_literal: true

module Schools
  module AddParticipants
    class WhoToAddForm
      include ActiveModel::Model
      include ActiveRecord::AttributeAssignment

      attr_accessor :participant_type

      validates :participant_type, inclusion: { in: %w[ect mentor] }

      def ect_chosen?
        participant_type == "ect"
      end

      def mentor_chosen?
        participant_type == "mentor"
      end
    end
  end
end
