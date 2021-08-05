# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schedule, type: :model do
  it { is_expected.to have_many(:milestones) }
  it { is_expected.to have_many(:participant_profiles) }
end
