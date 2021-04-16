# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoreInductionProgrammeChoiceForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:core_induction_programme_id).with_message("Select the training materials you want to use") }
  end
end
