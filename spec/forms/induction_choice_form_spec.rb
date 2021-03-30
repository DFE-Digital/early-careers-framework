# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionChoiceForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:programme_choice).with_message("Select one") }
  end
end
