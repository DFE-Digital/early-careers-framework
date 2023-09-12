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

  context ".adjustment_editable?" do
    context "paid statement" do
      subject { create :ecf_paid_statement }

      it "returns false" do
        subject.output_fee = true
        expect(subject.adjustment_editable?).to eql(false)

        subject.output_fee = false
        expect(subject.adjustment_editable?).to eql(false)
      end
    end

    context "non-paid statement" do
      context "output_fee is true" do
        subject { create :ecf_statement, output_fee: true }

        it "returns true" do
          expect(subject.adjustment_editable?).to eql(true)
        end
      end

      context "output_fee is false" do
        subject { create :ecf_statement, output_fee: false }

        it "returns false" do
          expect(subject.adjustment_editable?).to eql(false)
        end
      end
    end
  end

  context ".ecf?" do
    subject { build :ecf_statement }

    it { is_expected.to be_ecf }
    it { is_expected.to_not be_npq }
  end

  context ".npq?" do
    subject { build :npq_statement }

    it { is_expected.to_not be_ecf }
    it { is_expected.to be_npq }
  end

  context ".payable?" do
    context "payable statement" do
      subject { create :ecf_payable_statement }

      it { is_expected.to be_payable }
    end

    context "non payable statement" do
      subject { create :ecf_statement }

      it { is_expected.not_to be_payable }
    end
  end

  context "#mark_as_paid_at!" do
    let(:participant_declaration) do
      create(
        :ect_participant_declaration,
        :eligible,
      )
    end

    subject { participant_declaration.statements.first }

    it "sets marked_as_paid_at" do
      expect { subject.mark_as_paid_at! }.to change { subject.reload.marked_as_paid_at }
    end
  end

  context "#marked_as_paid?" do
    context "marked as paid statement" do
      subject { create(:ecf_paid_statement) }

      it "returns true" do
        expect(subject.marked_as_paid?).to eq(true)
      end
    end

    context "non marked as paid statement" do
      subject { create(:ecf_statement) }

      it "returns false" do
        expect(subject.marked_as_paid?).to eq(false)
      end
    end
  end
end
