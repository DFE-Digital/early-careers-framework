# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomeApiRequest, :with_default_schedules, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:participant_outcome).class_name("ParticipantOutcome::NPQ") }
  end
end
