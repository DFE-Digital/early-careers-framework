# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::Update do
  let(:ect) { create :ect }

  subject(:service) { described_class.new(ect) }

  describe "#call" do
    context "when changing the training status" do
      it "creates a participant profile status" do
        service.call(training_status: "withdrawn")
      end
    end
  end
end
