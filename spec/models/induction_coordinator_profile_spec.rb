# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionCoordinatorProfile, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_and_belong_to_many(:schools) }
end
