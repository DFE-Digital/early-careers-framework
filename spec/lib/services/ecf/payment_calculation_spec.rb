# frozen_string_literal: true

describe ::PaymentCalculator::Ecf::PaymentCalculation do
  let(:config) do
    {
      recruitment_target: 2000,
      band_a: BigDecimal(995, 10),
      retained_participants: {
        "Start" => 1900,
        "Retention 1" => 1700,
        "Retention 2" => 1500,
        "Retention 3" => 1000,
        "Retention 4" => 800,
        "Completion" => 500,
      },
    }
  end
  let(:result) { ::PaymentCalculator::Ecf::PaymentCalculation.call(config) }

  it "returns BigDecimal for all money outputs" do
    expect(result.dig(:output, :service_fees, :service_fee_per_participant)).to be_a(BigDecimal)
    expect(result.dig(:output, :service_fees, :service_fee_total)).to be_a(BigDecimal)
    expect(result.dig(:output, :service_fees, :service_fee_monthly)).to be_a(BigDecimal)
    expect(result.dig(:output, :output_payment, :per_participant)).to be_a(BigDecimal)
    if result[:output][:output_payment]
      result.dig(:output, :output_payment, :output_payment_schedule).each do |_key, value|
        expect(value[:per_participant]).to be_a(BigDecimal)
        expect(value[:subtotal]).to be_a(BigDecimal)
      end
    end
  end

  it "includes config in the output" do
    expect(result[:input]).to eq(config)
  end
end
