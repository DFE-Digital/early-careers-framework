# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoreInductionProgramme, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:course_years) }
  end
end
