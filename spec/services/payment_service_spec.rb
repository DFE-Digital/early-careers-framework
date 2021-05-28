# frozen_string_literal: true

require "rspec"

describe PaymentService do
  subject(:payment_service) { described_class.new }

  describe "#generate_html" do
    it "produces correct html output" do
      expected_html = <<~HTML
        <table>
          <thead>
            <tr>
              <th>Payment type</th>
              <th>Payment amount</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <th>Service fee (monthly)</th>
              <td>£19655.0</td>
            </tr>
            <tr>
              <th>Output payment (started)</th>
              <td>£216000.0</td>
            </tr>
            <tr>
              <th>Total payment amount</th>
              <td>£285655.0</td>
            </tr>
          </tbody>
        </table>
      HTML

      payment = {
        service_fee: BigDecimal(19_655, 2),
        output_payment: BigDecimal(216_000, 2),
        total_payment: BigDecimal(285_655, 2),
      }
      html = payment_service.generate_html(payment)
      expect(html).to eq(expected_html)
    end
  end
end
