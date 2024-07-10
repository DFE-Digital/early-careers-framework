# frozen_string_literal: true

module Schools
  module ChangeLeadProvider
    class LeadProviderStep < StoredStep
      attr_writer :lead_provider_id

      validates :lead_provider_id, presence: true

      def self.permitted_params
        [:lead_provider_id]
      end

      def lead_provider_id
        @lead_provider_id || stored_attrs[:lead_provider_id]
      end

      def previous_step
        :email
      end

      def next_step
        :check_your_answers
      end
    end
  end
end
