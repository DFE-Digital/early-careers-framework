# frozen_string_literal: true

module Schools
  module ChangeLeadProvider
    class StartStep < StoredStep
      attr_writer :answer

      validates :answer, presence: true

      def self.permitted_params
        [:answer]
      end

      def answer
        @answer || stored_attrs[:answer]
      end

      def previous_step
        :intro
      end

      def next_step
        if answer == "yes"
          wizard.participant_change_request? ? :email : :lead_provider
        elsif answer == "no"
          :contact_providers
        end
      end
    end
  end
end
