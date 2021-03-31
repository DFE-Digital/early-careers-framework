# frozen_string_literal: true

require "rails_helper"

RSpec.describe Task, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school_cohort) }
  end
end
