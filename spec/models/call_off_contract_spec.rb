# frozen_string_literal: true

require "rails_helper"

RSpec.describe CallOffContract, type: :model do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:band_a) { create(:participant_band, :band_a, call_off_contract: call_off_contract) }
  let(:band_b) { create(:participant_band, :band_b, call_off_contract: call_off_contract) }
  let(:band_c) { create(:participant_band, :band_c, call_off_contract: call_off_contract) }

  describe "associations" do
    it { is_expected.to have_many(:participant_bands) }
  end
end
