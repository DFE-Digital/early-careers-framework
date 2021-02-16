# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgressLabelComponent, type: :component do
  context "when receiving empty progress" do
    it "doesn't show anything when getting null" do
      render_inline(ProgressLabelComponent.new(progress: nil))
      expect(rendered_component).not_to include("govuk-tag")
    end

    it "doesn't show anything for empty string" do
      render_inline(ProgressLabelComponent.new(progress: nil))
      expect(rendered_component).not_to include("govuk-tag")
    end
  end

  context "when receiving not_started" do
    it "renders grey govuk tag" do
      render_inline(ProgressLabelComponent.new(progress: "not_started"))
      expect(rendered_component).to include('<strong class="govuk-tag app-task-list__tag govuk-tag--grey">not started</strong>')
    end
  end

  context "when receiving in_progress" do
    it "renders blue govuk tag" do
      render_inline(ProgressLabelComponent.new(progress: "in_progress"))
      expect(rendered_component).to include('<strong class="govuk-tag app-task-list__tag govuk-tag--blue">in progress</strong>')
    end
  end

  context "when receiving complete" do
    it "renders default govuk tag" do
      render_inline(ProgressLabelComponent.new(progress: "complete"))
      expect(rendered_component).to include('<strong class="govuk-tag app-task-list__tag ">complete</strong>')
    end
  end
end
