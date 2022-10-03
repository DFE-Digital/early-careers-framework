# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement::ECF::Paid do
  subject { create(:ecf_paid_statement) }

  describe "#paid?" do
    it { is_expected.to be_paid }
  end
end
