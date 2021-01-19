# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cohort, type: :model do
  it "can be created" do
    expect {
      Cohort.create(start_year: 2021)
    }.to change { Cohort.count }.by(1)
  end
end
