# frozen_string_literal: true

describe TimeTraveler do
  let(:app) { proc { [200, {}, Time.zone.now.to_s] } }
  let(:middleware) { described_class.new(app) }
  let(:request) { Rack::MockRequest.new(middleware) }
  let(:header_date) { "2021-01-02T03:04:05.000Z" }
  let(:expected_date) { Time.zone.parse(header_date) }
  let(:local_time) { Time.zone.local(2021, 8, 8, 10, 10, 0) }
  let(:some_other_date) { Timecop.travel(local_time) }

  context "when server date header passed" do
    it "changes the current date to the date from the header" do
      response = request.get("/", "HTTP_X_WITH_SERVER_DATE" => header_date)
      expect(Time.zone.parse(response.body)).to eq(expected_date)
    end
  end

  context "when date header not present" do
    context "with timecop travel" do
      before do
        Timecop.freeze(local_time)
      end
      after do
        Timecop.return
      end

      it "doesn't change the current date and matches current time" do
        response = request.get("/")
        expect(Time.zone.parse(response.body)).to eq(local_time)
      end
    end

    context "without timecop travel" do
      it "doesn't match wrong time" do
        response = request.get("/")
        expect(Time.zone.parse(response.body)).not_to eq(Time.zone.now - 1.second)
      end
    end
  end
end
