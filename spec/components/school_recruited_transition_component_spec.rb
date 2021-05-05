# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolRecruitedTransitionComponent, type: :component do
  subject(:component) { described_class.new school_cohort: school_cohort }
  # subject(:rendered) { Capybara.string(render_inline(component).to_html) }

  let(:school_cohort) { create :school_cohort, induction_programme_choice: induction_choice }
  let(:school) { school_cohort.school }
  let(:cohort) { school_cohort.cohort }

  context "when school did not choos cip" do
    let(:induction_choice) { SchoolCohort.induction_programme_choices.keys.without("core_induction_programme").sample }

    it { is_expected.not_to render }
  end

  context "when school has chosen core induction programme" do
    let(:induction_choice) { "core_induction_programme" }

    context "without fip partnership for given school" do
      it { is_expected.not_to render }
    end

    context "with fip partnership within challenge window" do
      let!(:partnership) { create :partnership, school: school, cohort: cohort }

      it { is_expected.to render }

      context "and the partnership has been challenged" do
        let!(:partnership) { create :partnership, :challenged, school: school, cohort: cohort }

        it { is_expected.not_to render }
      end

      describe "content" do
        subject(:rendered) { Capybara.string(render_inline(component).to_html) }
        let(:delivery_partner) { partnership.delivery_partner }

        it { is_expected.to have_content "#{delivery_partner.name} has confirmed" }
      end
    end
  end

  # it "renders yellow tag for to do" do
  #   rendered_component = render_inline(described_class.new(text: "To do")).to_html
  #   expect(rendered_component).to include("To do")
  #   expect(rendered_component).to include("yellow")
  # end
  #
  # it "renders green tag for done" do
  #   rendered_component = render_inline(described_class.new(text: "Done")).to_html
  #   expect(rendered_component).to include("Done")
  #   expect(rendered_component).to include("green")
  # end
  #
  # it "renders grey tag for unknown" do
  #   rendered_component = render_inline(described_class.new(text: "Test string")).to_html
  #   expect(rendered_component).to include("Test string")
  #   expect(rendered_component).to include("grey")
  # end
end
