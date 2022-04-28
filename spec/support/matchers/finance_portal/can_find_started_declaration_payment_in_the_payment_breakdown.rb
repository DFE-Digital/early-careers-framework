# frozen_string_literal: true

module Support
  module FindingStartedDeclarationPaymentInPaymentBreakdown
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_see_started_declaration_payment_for_lead_provider_in_payment_breakdown do |lead_provider_name, num_ects, num_mentors, num_declarations|
      match do |finance_user|
        sign_in_as finance_user

        report = Pages.finance_portal
                  .view_payment_breakdown
                  .complete(lead_provider_name)

        report.can_see_started_declaration_payment_amount_table?(num_ects, num_mentors, num_declarations)

        sign_out

        true
      rescue Capybara::ElementNotFound => e
        @error = e
        false
      end

      failure_message do |_sit|
        return @error unless @error.nil?

        "should #{with_description(@text, lead_provider_name, num_ects, num_mentors, num_declarations)}"
      end

      failure_message_when_negated do |_sit|
        "should not #{with_description(@text, lead_provider_name, num_ects, num_mentors, num_declarations)}"
      end

      description do
        "be able to find the started declaration payment in the payment breakdown for '#{lead_provider_name}' showing #{num_ects} ECTs, #{num_mentors} Mentors and #{num_declarations} Training Declarations"
      end

    private

      def with_description(text, lead_provider_name, num_ects, num_mentors, num_declarations)
        "have been able to find the started declaration payment in the payment breakdown for '#{lead_provider_name}' showing #{num_ects} ECTs, #{num_mentors} Mentors and #{num_declarations} Training Declarations within:\n===\n#{text}\n==="
      end
    end
  end
end
