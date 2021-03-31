# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolCohort, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:school) }
    it { is_expected.to have_many(:tasks) }
  end
end
