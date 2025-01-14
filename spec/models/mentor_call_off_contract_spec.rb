# frozen_string_literal: true

require "rails_helper"

RSpec.describe MentorCallOffContract, type: :model do
  let(:mentor_call_off_contract) { create(:mentor_call_off_contract) }

  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:lead_provider) }
  end
end
