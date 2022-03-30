# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule, type: :model do
  it { is_expected.to have_many(:schedule_milestones) }
  # TODO: uncomment in later PR
  # it { is_expected.to have_many(:milestones).through(:schedule_milestones) }
  it { is_expected.to have_many(:participant_profiles) }
end
