# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement do
  it { is_expected.to belong_to(:cohort) }

  describe "#paid?" do
    subject { create(:ecf_statement) }

    it { is_expected.not_to be_paid }
  end

  describe "scopes" do
    let(:today) { Date.current }

    describe ".payable" do
      subject { described_class.payable.to_sql }

      it { is_expected.to match(%("deadline_date" < '#{today}')) }
      it { is_expected.to match(%("payment_date" >= '#{today}')) }
    end

    describe ".closed" do
      subject { described_class.closed.to_sql }

      it { is_expected.to match(%("payment_date" < '#{today}')) }
    end

    describe ".with_future_deadline_date" do
      subject { described_class.with_future_deadline_date.to_sql }

      it { is_expected.to match(%("deadline_date" >= '#{today}')) }
    end

    describe ".upto" do
      let(:a_week_ago) { 1.week.ago.to_date }
      let(:fake_statement) { instance_double(Finance::Statement, deadline_date: a_week_ago) }

      subject { described_class.upto(fake_statement).to_sql }

      it { is_expected.to match(%("deadline_date" < '#{a_week_ago}')) }
    end
  end
end
