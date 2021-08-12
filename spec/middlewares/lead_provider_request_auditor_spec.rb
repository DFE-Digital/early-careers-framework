# frozen_string_literal: true

describe LeadProviderRequestAuditor, type: :request do
  context "when sending a request to an audited path" do
    it "saves the request details" do
      expect { post("/api/v1/participant-declarations.json") }.to change(ApiRequestAudit, :count).by(1)
    end
  end

  context "when sending a request to non-audited path" do
    it "changes the current date to the date from the header" do
      expect { get("/") }.not_to change(ApiRequestAudit, :count)
    end
  end
end
