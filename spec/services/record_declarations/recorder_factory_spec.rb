# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::RecorderFactory do
  let!(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }

  context "when passed a valid course" do
    it "succeeds when passed a 'ecf-induction' key" do
      expect(described_class.call("ecf-induction")).to eq("EarlyCareerTeacher")
    end

    it "succeeds when passed a 'ecf-mentor' key" do
      expect(described_class.call("ecf-mentor")).to eq("Mentor")
    end

    it "succeeds when passed 'npq-leading-teaching'" do
      expect(described_class.call("npq-leading-teaching")).to eq("NPQ")
    end
  end
end
