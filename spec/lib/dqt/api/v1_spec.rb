# frozen_string_literal: true

require "rails_helper"

module Dqt
  class Api
    describe V1 do
      subject(:v1) { described_class.new(client: double("client")) }

      describe "#dqt_record" do
        it "returns DQTRecord" do
          expect(v1.dqt_record).to be_an_instance_of(described_class::DQTRecord)
        end

        it "memoizes DQTRecord" do
          expect(v1.dqt_record).to be(v1.dqt_record)
        end
      end
    end
  end
end
