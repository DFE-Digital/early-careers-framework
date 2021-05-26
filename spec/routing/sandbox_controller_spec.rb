# frozen_string_literal: true

RSpec.describe SandboxController do
  before do
    allow(Rails).to receive(:env).and_return ActiveSupport::EnvironmentInquirer.new(environment.to_s)
    Rails.application.reload_routes!
  end

  describe "Based on rails environment routes" do
    context "when it is not sandbox environment" do
      let(:environment) { %i[development test production].sample }

      it "routes GET / to StartController#index" do
        expect(get: "/").to route_to(controller: "start", action: "index")
      end
    end

    context "when it is sandbox environment" do
      let(:environment) { :sandbox }

      it "routes GET / to SandboxController#show" do
        expect(get: "/").to route_to(controller: "sandbox", action: "show")
      end
    end
  end
end
