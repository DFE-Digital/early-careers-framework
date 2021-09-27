# frozen_string_literal: true

RSpec.shared_examples "a participant service for npq" do
  context "when valid user is an NPQ" do
    it "fails when course is for an early career teacher" do
      params = given_params.merge({ course_identifier: "ecf-induction" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for a mentor" do
      params = given_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for a different npq-course" do
      params = given_params.merge({ course_identifier: "npq-headship" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
