# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement do
  it { is_expected.to belong_to(:cohort) }

  describe "#paid?" do
    subject { create(:ecf_statement) }

    it { is_expected.not_to be_paid }
  end
end
