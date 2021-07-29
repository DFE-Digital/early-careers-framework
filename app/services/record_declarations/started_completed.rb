# frozen_string_literal: true

module RecordDeclarations
  module StartedCompleted
    extend ActiveSupport::Concern

    included do
      extend StartedCompletedClassMethods
    end

    module StartedCompletedClassMethods
      def required_params
        %i[user_id cpd_lead_provider declaration_type declaration_date course_identifier raw_event]
      end
    end
  end
end
