# frozen_string_literal: true

module Support
  module FindingOtherFeesInFinancePortal
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_see_other_fees_for_the_lead_provider_in_the_finance_portal do |lead_provider_name, num_ects, num_mentors|
      match do |finance_user|
        sign_in_as finance_user

        portal = Pages::FinancePortal.loaded
        wizard = portal.view_payment_breakdown
        report = wizard.complete lead_provider_name

        @text = page.find("main").text

        report.can_see_other_fees_table?(num_ects, num_mentors)

        sign_out

        true
      rescue Capybara::ElementNotFound => e
        @error = e

        sign_out

        false
      end

      failure_message do |_sit|
        return @error unless @error.nil?

        "should #{with_description(@text, lead_provider_name, num_ects, num_mentors)}"
      end

      failure_message_when_negated do |_sit|
        "should not #{with_description(@text, lead_provider_name, num_ects, num_mentors)}"
      end

      description do
        "be able to find the other fees in the payment breakdown for '#{lead_provider_name}' showing #{num_ects} ECTs and #{num_mentors} Mentors"
      end

    private

      def with_description(text, lead_provider_name, num_ects, num_mentors)
        "have been able to find the other fees in the payment breakdown for '#{lead_provider_name}' showing #{num_ects} ECTs and #{num_mentors} Mentors within:\n===\n#{text}\n==="
      end
    end
  end
end
