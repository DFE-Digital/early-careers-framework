# frozen_string_literal: true

module Pages
  class FinancePaymentBreakdownReport
    include Capybara::DSL

    def can_see_recruitment_summary?(num_ects, num_mentors)
      num_participants = num_ects + num_mentors

      within ".breakdown-summary-recruitment" do
        has_text? "Current ECTs #{num_ects} Current Mentors #{num_mentors}"
        has_text? "Total #{num_participants}"
      end
    end

    def can_see_payment_summary?(num_declarations)
      within ".breakdown-summary-payment" do
        has_text? "Output fee #{num_declarations}"
      end
    end

    def can_see_started_declaration_payment_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations
      total_payment = total_in_band == 0 ? "0.00" : "119.40"

      within all(".output-payments-table")[0] do
        has_text? "Payment Band A £119.40 #{total_in_band} £#{total_payment}"
      end
    end

    def can_see_retained_1_declaration_payment_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations
      total_payment = total_in_band == 0 ? "0.00" : "119.40"

      within all(".output-payments-table")[1] do
        has_text? "Payment Band A £119.40 #{total_in_band} £#{total_payment}"
      end
    end

    def can_see_other_fees_table?(num_ects, num_mentors)
      num_participants = num_ects + num_mentors
      total_payment = num_participants == 0 ? "0.00" : "100.00"

      within ".other-fees-table" do
        has_text? "Uplift fee #{num_participants}"
        has_text? "Uplift fee £100.00 #{num_participants} £#{total_payment}"
      end
    end
  end
end
