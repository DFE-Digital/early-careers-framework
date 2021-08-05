# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Milestone, type: :model do
  it { is_expected.to belong_to(:schedule) }
end
