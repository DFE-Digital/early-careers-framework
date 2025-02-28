# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::Contracts::ECTMentor, type: :component do
  let(:statement) { instance_double(Finance::Statement::ECF, contract:, mentor_contract:) }
  let(:component) { described_class.new(statement:) }
  let(:contract) do
    instance_double(
      CallOffContract,
      bands:,
      recruitment_target: 999,
      revised_target: 1111,
    )
  end
  let(:bands) do
    [
      instance_double(ParticipantBand, min: 0, max: 10, per_participant: 1000, output_payment_percentage: 60, service_fee_percentage: 40),
      instance_double(ParticipantBand, min: 11, max: 20, per_participant: 2000, output_payment_percentage: 60, service_fee_percentage: 40),
      instance_double(ParticipantBand, min: 21, max: 30, per_participant: 2000, output_payment_percentage: 60, service_fee_percentage: 40),
      instance_double(ParticipantBand, min: 31, max: 40, per_participant: 2000, output_payment_percentage: 60, service_fee_percentage: 40),
    ]
  end
  let(:mentor_contract) do
    instance_double(
      MentorCallOffContract,
      recruitment_target: 888,
      payment_per_participant: 1_000,
    )
  end

  let(:summary_list) do
    subject.css(".contract-information .govuk-summary-list").map do |list|
      list.css(".govuk-summary-list__row").map do |row|
        row.css(".govuk-summary-list__key, .govuk-summary-list__value").map { |v| v.text.strip }
      end
    end
  end

  let(:band_table) do
    subject.css(".contract-information .govuk-table .govuk-table__row").map do |row|
      row.css(".govuk-table__header, .govuk-table__cell").map { |v| v.text.strip }
    end
  end

  subject { render_inline(component) }

  it "has correct contract values" do
    expect(summary_list[0][0]).to eq(%w[ECTs])

    expect(summary_list[1][0]).to eq(["ECTs recruitment target", "999"])
    expect(summary_list[1][1]).to eq(["Revised ECTs recruitment target (+115%)", "1111"])

    expect(summary_list[2][0]).to eq(%w[Mentors])

    expect(summary_list[3][0]).to eq(["Mentors recruitment target", "888"])
    expect(summary_list[3][1]).to eq(["Payment per participant", "£1,000.00"])
  end

  it "has correct bands" do
    expect(band_table[0]).to eq([
      "ECT payment bands",
      "Min",
      "Max",
      "Payment per participant",
    ])

    expect(band_table[1]).to eq([
      "Band A",
      "0",
      "10",
      "£1,000.00",
    ])

    expect(band_table[2]).to eq([
      "Band B",
      "11",
      "20",
      "£2,000.00",
    ])

    expect(band_table[3]).to eq([
      "Band C",
      "21",
      "30",
      "£2,000.00",
    ])

    expect(band_table[4]).to eq([
      "New target",
      "31",
      "40",
      "£2,000.00",
    ])
  end
end
