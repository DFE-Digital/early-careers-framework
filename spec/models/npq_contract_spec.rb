# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQContract do
  it { is_expected.to belong_to(:cohort) }
end
