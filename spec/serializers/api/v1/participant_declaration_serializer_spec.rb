# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ParticipantDeclarationSerializer do
  describe "#state" do
    let(:declaration) do
      build(
        :participant_declaration,
        updated_at: 10.seconds.ago,
        state: "awaiting_clawback",
      )
    end

    it "dasherizes the value" do
      result = described_class.new(declaration).serializable_hash
      expect(result[:data][:attributes][:state]).to eql("awaiting-clawback")
    end
  end
end
