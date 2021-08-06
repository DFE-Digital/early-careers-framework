# frozen_string_literal: true

describe TimeTraveler do
  context "when called with a POST request" do
    let(:app) { proc { [200, {}, %w[Live]] } }
    let(:middleware) { described_class.new(app) }
    let(:request) { Rack::MockRequest.new(middleware) }
    let(:header_date) { "2021-01-02T03:04:05.000Z" }
    let(:expected_date) { Time.zone.parse(header_date) }

    context "when server date header passed" do
      it "passes the request through unchanged" do
        request.get("/", "X_WITH_SERVER_DATE" => header_date) do
          expect(Time.zone.now).to eq(expected_date)
        end
      end
    end
  end
end
