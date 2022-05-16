# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe NPQApplicationSerializer do
      let(:application) do
        create(
          :npq_application,
          targeted_delivery_funding_eligibility: true,
        )
      end

      subject { described_class.new(application) }

      describe "serialization" do
        it "outputs correctly" do
          output = subject.serializable_hash

          expect(output[:data][:attributes][:targeted_delivery_funding_eligibility]).to eql(true)
        end
      end
    end
  end
end
