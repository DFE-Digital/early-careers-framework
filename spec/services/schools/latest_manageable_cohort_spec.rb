# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::LatestManageableCohort do
  describe "#call" do
    let(:school) { create(:seed_school) }

    subject(:service_call) { described_class.call(school:) }

    it "returns the latest available cohort in which the school can participant" do
      expect(service_call).to eq Cohort.current
    end
  end
end
