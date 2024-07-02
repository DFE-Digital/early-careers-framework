# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class LeadProviderStep < DfE::Wizard::Step
        attr_accessor :lead_provider_id

        validates :lead_provider_id, presence: true

        def self.permitted_params
          [:lead_provider_id]
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
end
