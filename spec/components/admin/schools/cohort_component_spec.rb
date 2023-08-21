# frozen_string_literal: true

RSpec.describe Admin::Schools::CohortComponent, type: :component do
  let(:school) { FactoryBot.create(:seed_school) }
  let(:cohort) { FactoryBot.create(:seed_cohort) }
  let(:school_cohort) { FactoryBot.create(:seed_school_cohort, school:, cohort:) }
  let(:partnership) { FactoryBot.create(:seed_partnership, :valid, school:, cohort:) }
  let(:relationships) { FactoryBot.create_list(:seed_partnership, 2, :valid, school:, cohort:, relationship: true) }
  let(:partnerships_and_relationships) { [partnership, *relationships] }
  let(:kwargs) { { school:, cohort:, school_cohort:, partnerships_and_relationships: } }

  let(:relationship_matcher) { ".govuk-summary-card" } # each relationship is rendered within a summary card
  let(:partnership_matcher) { ".govuk-button--secondary" } # each partnership has a challenge button
  subject { Admin::Schools::CohortComponent.new(**kwargs) }

  describe "rendering" do
    before { render_inline(subject) }

    it "renders a heading with the cohort's year followed by 'partnership'" do
      expect(rendered_content).to have_css("h2", text: "#{cohort.start_year} programme")
    end

    context "when partnerships are present" do
      it("renders the partnerships") { expect(rendered_content).to have_css(partnership_matcher, text: "Challenge") }
    end

    context "when no partnerships are present" do
      let(:partnership) { nil }

      it("renders no partnerships") { expect(rendered_content).not_to have_css(partnership_matcher) }
    end

    context "when relationships are present" do
      it("renders the relationships") { expect(rendered_content).to have_css(relationship_matcher) }
    end

    context "when no relationships are present" do
      let(:relationships) { nil }

      it("renders no relationships") { expect(rendered_content).not_to have_css(relationship_matcher) }
    end
  end

  describe "methods" do
    describe "#empty?" do
      let(:partnerships_and_relationships) { [] }

      context "when there are relationships and partnerships" do
        it { is_expected.to be_empty }
      end
    end
  end

  describe "initialization" do
    before do
      allow_any_instance_of(Admin::Schools::CohortComponent).to receive(:with_partnership_component).and_return(true)
      allow_any_instance_of(Admin::Schools::CohortComponent).to receive(:with_relationship_component).and_return(true)

      render_inline(subject)
    end

    it "passes the partnership information to the partnership slots" do
      expect(subject).to have_received(:with_partnership_component).with(school:, school_cohort:, partnership:)
    end

    it "passes the relationship information to the relationship slots" do
      relationships.each do |relationship|
        expect(subject).to have_received(:with_relationship_component).with(school:, school_cohort:, relationship:, superuser: false)
      end
    end
  end
end
