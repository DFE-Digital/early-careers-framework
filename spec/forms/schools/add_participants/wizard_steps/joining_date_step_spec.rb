# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::JoiningDateStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::TransferWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    before do
      allow(wizard).to receive(:existing_induction_start_date).and_return(1.week.ago)
    end

    it { is_expected.to validate_presence_of(:start_date) }

    it "validates that :start_date is later than the existing induction start" do
      start = 2.weeks.ago
      step.start_date = { 1 => start.year, 2 => start.month, 3 => start.day }
      expect(step).not_to be_valid
      expect(step.errors[:start_date]).to be_present

      start = 1.day.ago
      step.start_date = { 1 => start.year, 2 => start.month, 3 => start.day }
      expect(step).to be_valid
    end

    it "validates that :start_date is not later than a year in the future" do
      requested_date = Date.current + 1.year + 1.day
      step.start_date = { 1 => requested_date.year, 2 => requested_date.month, 3 => requested_date.day }
      expect(step).not_to be_valid
      expect(step.errors[:start_date]).to be_present

      requested_date = Date.current + 1.year
      step.start_date = { 1 => requested_date.year, 2 => requested_date.month, 3 => requested_date.day }
      expect(step).to be_valid
    end
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[start_date]
    end
  end

  describe "#next_step" do
    it "returns :email" do
      expect(step.next_step).to eql :email
    end
  end
end
