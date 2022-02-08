# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionProgramme, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school_cohort) }
    it { is_expected.to belong_to(:partnership).optional }
    it { is_expected.to belong_to(:core_induction_programme).optional }

    it { is_expected.to have_many(:induction_records) }
    it { is_expected.to have_many(:active_induction_records) }
    it { is_expected.to have_many(:participant_profiles).through(:active_induction_records) }
  end
end
