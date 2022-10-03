# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement::NPQ::Paid do
  subject { create(:npq_paid_statement) }

  describe "#paid?" do
    it { is_expected.to be_paid }
  end
end
