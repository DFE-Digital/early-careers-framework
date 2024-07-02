# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class EmailStep < DfE::Wizard::Step
        attr_accessor :answer, :email

        validates :answer, presence: true
        validates :email, presence: true, if: -> { answer == "no" }

        def self.permitted_params
          %i[answer email]
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
end
