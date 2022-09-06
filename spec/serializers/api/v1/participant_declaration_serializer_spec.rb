# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ParticipantDeclarationSerializer, :with_default_schedules do
  describe "#state" do
    let(:declaration) do
      create(:ect_participant_declaration, :awaiting_clawback)
    end

    it "dasherizes the value" do
      result = described_class.new(declaration).serializable_hash
      expect(result[:data][:attributes][:state]).to eql("awaiting-clawback")
    end
  end
end
