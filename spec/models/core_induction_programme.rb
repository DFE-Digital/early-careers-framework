# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoreInductionProgramme, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:early_career_teacher_profiles) }
    it { is_expected.to have_many(:early_career_teachers).through(:early_career_teacher_profiles) }
  end
end
