# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::EventFactory do
  context 'when passed a valid string' do

    it 'succeeds when passed a "started" key' do
      expect(described_class.call("started")).to eq("Started")
    end

    it 'succeeds when passed "retained-1"' do
      expect(described_class.call("retained-1")).to eq("Retained")
    end

  end
end
