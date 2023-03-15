# frozen_string_literal: true

module Schools
  module AddParticipants
    class BaseWizard
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      class InvalidStep < StandardError; end

      def ect_participant?
        false
      end

      def mentor_participant?
        false
      end

      def sit_mentor?
        false
      end
    end
  end
end
