# frozen_string_literal: true

RSpec.shared_examples "JSON Participant Withdrawal endpoint" do
  let(:parsed_response) { JSON.parse(response.body) }

  it "returns an error when the participant is already withdrawn" do
    2.times { put url, params: }

    expect(response).not_to be_successful
  end

  context "with an invalid request" do
    context "with invalid reason" do
      context "when reason is blank" do
        before { params[:data][:attributes][:reason] = "" }

        it "returns and error with the reason for the error" do
          put(url, params:)

          expect(response).not_to be_successful
          expect(parsed_response.dig("errors", 0, "detail")).to include("The property '#/reason' must be a valid reason")
        end
      end
    end

    context "when reason is not included in the list" do
      before { params[:data][:attributes][:reason] = "erroneous-reason" }

      it "returns and error with the reason for the error" do
        put(url, params:)

        expect(response).not_to be_successful
        expect(parsed_response.dig("errors", 0, "detail")).to include("The property '#/reason' must be a valid reason")
      end
    end
  end

  context "when new_programme_types feature on" do
    let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: } } } }
    before { FeatureFlag.activate(:new_programme_types) }

    context "when reason is 'school-left-fip'" do
      let(:reason) { "school-left-fip" }

      it "participant is withdrawn with correct reason" do
        put(url, params:)

        expect(response).not_to be_successful
        expect(parsed_response.dig("errors", 0, "detail")).to include("The property '#/reason' must be a valid reason")
      end
    end

    context "when reason is 'school-left-provider-led'" do
      let(:reason) { "school-left-provider-led" }

      it "participant is withdrawn with correct reason" do
        put(url, params:)

        expect(response).to be_successful
        if url.match?("/v3/")
          expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "withdrawal", "reason")).to eql("school-left-provider-led")
        end
      end
    end
  end

  context "when new_programme_types feature off" do
    let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: } } } }
    before { FeatureFlag.deactivate(:new_programme_types) }

    context "when reason is 'school-left-fip'" do
      let(:reason) { "school-left-fip" }

      it "participant is withdrawn with correct reason" do
        put(url, params:)

        expect(response).to be_successful
        if url.match?("/v3/")
          expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "withdrawal", "reason")).to eql("school-left-fip")
        end
      end
    end

    context "when reason is 'school-left-provider-led'" do
      let(:reason) { "school-left-provider-led" }

      it "participant is withdrawn with correct reason" do
        put(url, params:)

        expect(response).not_to be_successful
        expect(parsed_response.dig("errors", 0, "detail")).to include("The property '#/reason' must be a valid reason")
      end
    end
  end
end
