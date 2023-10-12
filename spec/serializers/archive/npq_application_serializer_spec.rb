# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::NPQApplicationSerializer do
  let(:npq_application) { create(:seed_npq_application, :valid) }

  subject { described_class.new(npq_application) }

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq npq_application.id
      expect(data[:type]).to eq :npq_application

      attrs = data[:attributes]
      npq_application.attributes.except(*%w[id updated_at]).each do |k, v|
        expect(attrs[k.to_sym]).to eq v
      end
    end
  end
end
