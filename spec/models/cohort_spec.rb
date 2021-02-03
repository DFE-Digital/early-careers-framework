# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cohort, type: :model do
  it "can be created" do
    expect {
      Cohort.create(start_year: 2021)
    }.to change { Cohort.count }.by(1)
  end

  describe "display_name" do
    it "displays the correct years" do
      expect(Cohort.new(start_year: 2021).display_name).to eq "2021 to 2023"
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:early_career_teacher_profiles) }
    it { is_expected.to have_many(:early_career_teachers).through(:early_career_teacher_profiles) }
  end
end
