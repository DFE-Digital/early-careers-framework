# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:early_career_teacher_profile) }
  end
end
