# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PartnershipFinalisationJob" do
  describe "#perform" do
    it "calls finalise! on the partnership request" do
      with_versioning do
        partnership_request = create(:partnership_request)
        expect(partnership_request).to receive(:finalise!)

        PartnershipFinalisationJob.new.perform(partnership_request)
      end
    end

    it "does nothing when the partnership request has been destroyed" do
      with_versioning do
        partnership_request = create(:partnership_request)
        expect(partnership_request).not_to receive(:finalise!)
        PartnershipFinalisationJob.perform_later(partnership_request)
        partnership_request.destroy!

        expect { Delayed::Worker.new.work_off }.not_to(change { Partnership.count })
        expect(PartnershipRequest.count).to eql 0
        expect(Partnership.count).to eql 0
      end
    end
  end
end
