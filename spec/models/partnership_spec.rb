# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partnership, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:cohort) }
  end
end
