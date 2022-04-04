# frozen_string_literal: true

RSpec.describe Finance::ScheduleMilestone do
  it { is_expected.to belong_to :schedule }
  it { is_expected.to belong_to :milestone }
end
