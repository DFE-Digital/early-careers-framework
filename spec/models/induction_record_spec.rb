# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionRecord, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:induction_programme) }
    it { is_expected.to belong_to(:participant_profile) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
  end
end
