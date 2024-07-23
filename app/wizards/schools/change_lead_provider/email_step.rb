# frozen_string_literal: true

module Schools
  module ChangeLeadProvider
    class EmailStep < StoredStep
      attr_writer :answer, :email

      validates :answer, presence: true
      validates :email, presence: true, if: -> { answer == "no" }

      def self.permitted_params
        %i[answer email]
      end

      def answer
        @answer || stored_attrs[:answer]
      end

      def email
        @email || stored_attrs[:email]
      end

      def previous_step
        :start
      end

      def next_step
        :lead_provider
      end
    end
  end
end
