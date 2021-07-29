# frozen_string_literal: true

module RecordDeclarations
  module Retained
    extend ActiveSupport::Concern

    included do
      extend RetainedClassMethods
    end

    module RetainedClassMethods
      def required_params
        %i[user_id cpd_lead_provider declaration_type declaration_date course_identifier evidence_held raw_event]
      end
    end
  end
end
