# frozen_string_literal: true

RSpec.describe SandboxController do
  describe "Based on rails environment routes" do
    before do
      allow(Rails).to receive(:env).and_return ActiveSupport::EnvironmentInquirer.new(environment.to_s)
      Rails.application.reload_routes!
    end

    after(:context) do
      Rails.application.reload_routes!
    end

    context "when it is not sandbox environment" do
      let(:environment) { %i[development test production].sample }

      it "routes GET / to StartController#index" do
        expect(get: "/").to route_to(controller: "start", action: "index")
      end
    end

    context "when it is sandbox environment" do
      let(:environment) { :sandbox }

      before do
        allow(Rails.env).to receive(:sandbox?).and_return(true)
        Rails.application.reload_routes!
      end

      it "routes GET /sandbox to SandboxController#show" do
        expect(get: "/sandbox").to route_to(controller: "sandbox", action: "show")
      end
    end
  end
end
