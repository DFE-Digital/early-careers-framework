# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantIdChange, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("User") }
    it { is_expected.to belong_to(:from_participant).class_name("User") }
    it { is_expected.to belong_to(:to_participant).class_name("User") }
  end
end
