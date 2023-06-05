# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrainingRecordState, type: :model do
  describe "relationships" do
    it { is_expected.to belong_to(:participant_profile) }
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:delivery_partner) }
  end
end
