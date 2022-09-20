# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Participants::ChangeInductionStartDateForm, type: :model do
  let(:induction_start_date) { 3.weeks.from_now.to_date }
  subject { described_class.new(induction_start_date:) }

  describe "initializing with an induction_start_date 3 weeks in the future" do
    it { is_expected.to have_attributes(induction_start_date:) }
    it { is_expected.to validate_presence_of(:induction_start_date).with_message("Enter an induction start date") }
  end

  describe "#to_h" do
    it "returns a hash containing the induction_start_date" do
      expect(subject.to_h).to eql({ induction_start_date: })
    end
  end
end
