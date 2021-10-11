# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchBox, type: :component do
  context "with filters" do
    subject do
      described_class.new(
        query: "",
        filters: [
          {
            field: :type,
            value: "ParticipantProfile::NPQ",
            options: [
              OpenStruct.new(id: "", name: ""),
              OpenStruct.new(id: "ParticipantProfile::ECT", name: "ECT"),
              OpenStruct.new(id: "ParticipantProfile::Mentor", name: "Mentor"),
              OpenStruct.new(id: "ParticipantProfile::NPQ", name: "NPQ"),
            ],
          },
        ],
      )
    end

    it "displays filter" do
      with_request_url "/admin/participants" do
        dom = render_inline(subject)

        expect(dom).to have_css("select[name=type]")
        expect(dom.css("select option").count).to eql(4)
      end
    end

    it "pre-selects option of passed value" do
      with_request_url "/admin/participants" do
        dom = render_inline(subject)

        expect(dom.css("select option[selected]").text).to eql("NPQ")
      end
    end
  end
end
