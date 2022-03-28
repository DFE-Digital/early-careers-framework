# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement do
  it { is_expected.to belong_to(:cohort).optional(true) }
end
