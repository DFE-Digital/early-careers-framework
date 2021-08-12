# frozen_string_literal: true

describe LeadProviderRequestAuditor do
  let(:app) { proc { [200, {}, Time.zone.now.to_s] } }
  let(:middleware) { described_class.new(app) }
  let(:request) { Rack::MockRequest.new(middleware) }

  context "when sending a request to an audited path" do
    it "saves the request details" do
      expect { request.post("/api/v1/participant-declarations.json") }.to change(ApiRequestAudit, :count).by(1)
    end
  end

  context "when sending a request to non-audited path" do
    it "changes the current date to the date from the header" do
      expect { request.get("/") }.not_to change(ApiRequestAudit, :count)
    end
  end
end
