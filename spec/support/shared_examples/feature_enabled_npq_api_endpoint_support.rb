# frozen_string_literal: true

RSpec.shared_examples "Feature enabled NPQ API endpoint" do |action, url|
  context "when disable_npq_endpoints is true" do
    before do
      FeatureFlag.activate(:disable_npq_endpoints)
    end

    it "raises routing error" do
      expect {
        case action
        when "GET"
          get url
        when "POST"
          post url
        when "PUT"
          put url
        when "PATCH"
          patch url
        end
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
