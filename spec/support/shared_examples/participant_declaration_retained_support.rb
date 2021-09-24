# frozen_string_literal: true

RSpec.shared_examples "a retained participant declaration service" do
  it_behaves_like "a participant declaration service"

  context "when evidence held is invalid" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(given_params.merge(evidence_held: "invalid")) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
