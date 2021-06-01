# frozen_string_literal: true

RSpec.describe SandboxController do
  describe "Based on rails environment routes" do
    context "when it is not sandbox environment" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        Rails.application.reload_routes!
      end

      it "routes GET / to StartController#index" do
        expect(get: "/").to route_to(controller: "start", action: "index")
      end
    end

    context "when it is sandbox environment" do
      before do
        allow(Rails.env).to receive(:sandbox?).and_return(true)
        Rails.application.reload_routes!
      end

      it "routes GET / to SandboxController#show" do
        expect(get: "/").to route_to(controller: "sandbox", action: "show")
      end
    end
  end
end
