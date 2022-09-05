# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeclarationDateValidator do
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      attribute :declaration_date, :datetime
      attr_reader :raw_declaration_date

      validates :declaration_date, declaration_date: true

      def declaration_date=(raw_date)
        self.raw_declaration_date = raw_date
        super
      end

      def milestone; end

    private

      attr_writer :raw_declaration_date
    end
  end

  let(:declaration_date) { Date.new(2022, 1, 30) }
  let(:milestone_date)   { declaration_date + 1.day }
  let(:start_date)       { declaration_date - 1.day }

  subject { model_class.new(declaration_date: declaration_date.rfc3339) }

  before do
    allow(milestone).to receive(:start_date).and_return(start_date)
    allow(milestone).to receive(:milestone_date).and_return(milestone_date)
  end

  describe "#declaration_date" do
    let(:milestone) { instance_double(Finance::Milestone) }

    before { allow(subject).to receive(:milestone).and_return(milestone) }

    describe "the declaration date has the right format" do
      context "when declaration date is invalid" do
        subject { model_class.new(declaration_date: "2021-06-21 08:46:29") }

        it "has a meaningful error", :aggregate_failures do
          expect(subject).to be_invalid
          expect(subject.errors.messages_for(:declaration_date)).to include("The property '#\/declaration_date' must be a valid RCF3339 date")
        end
      end
    end

    describe "declaration_date is within milestone" do
      context "when before the milestone start" do
        let(:start_date) { declaration_date + 1.day }

        it "has a meaningful error", :aggregate_failures do
          expect(subject).to be_invalid
          expect(subject.errors.messages_for(:declaration_date)).to eq(["The property '#/declaration_date' can not be before milestone start"])
        end
      end

      context "when at the milestone start" do
        let(:start_date) { declaration_date }

        it { is_expected.to be_valid }
      end

      context "when in the middle of milestone" do
        it { is_expected.to be_valid }
      end

      context "when at the milestone end" do
        let(:milestone_date) { declaration_date }

        it { is_expected.to be_valid }
      end

      context "when after the milestone start" do
        let(:milestone_date) { declaration_date - 1.day }

        it "has a meaningfull error", :aggregate_failures do
          expect(subject).to be_invalid
          expect(subject.errors.messages_for(:declaration_date))
            .to eq(["The property '#/declaration_date' can not be after milestone end"])
        end
      end
    end
  end
end
