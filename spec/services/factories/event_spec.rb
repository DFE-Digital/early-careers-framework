# frozen_string_literal: true

require "rails_helper"

RSpec.describe Factories::Event do
  context "when passed a valid string" do
    it 'succeeds when passed a "started" key' do
      expect(described_class.call("started")).to eq("Started")
    end

    it 'succeeds when passed "retained-1"' do
      expect(described_class.call("retained-1")).to eq("Retained")
    end

    it 'succeeds when passed "retained-2"' do
      expect(described_class.call("retained-2")).to eq("Retained")
    end

    it 'succeeds when passed "retained-3"' do
      expect(described_class.call("retained-3")).to eq("Retained")
    end

    it 'succeeds when passed "retained-4"' do
      expect(described_class.call("retained-4")).to eq("Retained")
    end

    it 'succeeds when passed a "completed" key' do
      expect(described_class.call("completed")).to eq("Started")
    end
  end
end
