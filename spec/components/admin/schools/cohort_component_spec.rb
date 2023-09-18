# frozen_string_literal: true

RSpec.describe Admin::Schools::CohortComponent, type: :component do
  let(:induction_programme_choice) { "full_induction_programme" }
  let(:school) { FactoryBot.create(:seed_school) }
  let(:cohort) { FactoryBot.create(:seed_cohort) }
  let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :fip, school:, cohort:, induction_programme_choice:) }
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

    context "when school is FIP" do
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

      context "when no school cohort, partnerships or relationships are present" do
        let(:partnership) { nil }
        let(:relationships) { nil }
        let(:school_cohort) { nil }

        it("shows an message explaining there is no programme") do
          expect(page).to have_content("No induction programme chosen for #{school.name} in #{cohort.academic_year}")
        end

        it "renders a link styled as a secondary button so admins can set one up" do
          expect(page).to have_link("Choose an induction programme", href: admin_school_change_programme_path(id: cohort.start_year, school_id: school.slug), class: "govuk-button--secondary")
        end
      end

      context "when there is a school cohort but there is not partnership or relationships" do
        let(:partnership) { nil }
        let(:relationships) { nil }

        it "displays the training programme" do
          expect(page).to have_content("Training programme")
          expect(page).to have_content("Working with a DfE-funded provider")
        end

        it "contains a link that allows the induction programme to be changed" do
          expect(page).to have_link("Change induction programme", href: admin_school_change_programme_path(id: cohort.start_year, school_id: school.slug))
        end
      end
    end

    context "when school is CIP" do
      let(:induction_programme_choice) { "core_induction_programme" }

      it("renders the correct description") { expect(page).to have_content("Using DfE-accredited materials") }
    end
  end

  describe "methods" do
    describe "#empty?" do
      let(:school_cohort) { nil }

      context "when there are no school cohorts" do
        it { is_expected.to be_empty }
      end
    end

    describe "#training_programme" do
      {
        "core_induction_programme" => "Using DfE-accredited materials",
        "design_our_own"           => "Designing their own training",
        "no_early_career_teachers" => "No ECTs this year",
      }.each do |training_programme, description|
        describe "training programme '#{training_programme}" do
          let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :with_cohort, induction_programme_choice: training_programme, school:) }

          it("has description #{description}") { expect(subject.training_programme).to eql(description) }
        end
      end
    end

    describe "#change_programme_href" do
      before { render_inline(subject) }

      it "is the change programme path with appropriate params" do
        expected = %(/admin/schools/#{school.slug}/cohorts/#{school_cohort.start_year}/change-programme)
        expect(subject.change_programme_href).to eql(expected)
      end
    end

    describe "#change_materials_href" do
      before { render_inline(subject) }

      it "is the change programme path with appropriate params" do
        expected = %(/admin/schools/#{school.slug}/cohorts/#{school_cohort.start_year}/change-training-materials)
        expect(subject.change_materials_href).to eql(expected)
      end
    end

    describe "#materials" do
      let(:default_induction_programme) { FactoryBot.create(:seed_induction_programme, :cip, :with_school_cohort, :with_core_induction_programme, school:) }
      let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :with_cohort, school:, default_induction_programme:) }

      it "returns the default induction programme's core induction programme name" do
        expected = school_cohort.default_induction_programme.core_induction_programme.name
        expect(subject.materials).to eql(expected)
      end
    end

    describe "#has_partnerships_or_relationships?" do
      context "when there is a partnership and some relationships" do
        it { is_expected.to have_partnerships_or_relationships }
      end

      context "when there is a partnership but no relationships" do
        let(:relationships) { nil }
        it { is_expected.not_to have_partnerships_or_relationships }
      end

      context "when there are relationships but no partnership" do
        let(:partnership) { nil }
        it { is_expected.not_to have_partnerships_or_relationships }
      end

      context "when there is no partnership and there are no relationships" do
        let(:partnership) { nil }
        let(:relationships) { nil }
        it { is_expected.not_to have_partnerships_or_relationships }
      end
    end

    describe "#cip?" do
      let(:induction_programme_choice) { "core_induction_programme" }

      it { is_expected.to be_cip }
      it { is_expected.not_to be_fip }
      it { is_expected.not_to be_other }
    end

    describe "#fip?" do
      let(:induction_programme_choice) { "full_induction_programme" }

      it { is_expected.to be_fip }
      it { is_expected.not_to be_cip }
      it { is_expected.not_to be_other }
    end

    describe "#other?" do
      %w[design_our_own no_early_career_teachers school_funded_fip].each do |other_programme|
        context "when #{other_programme}" do
          let(:induction_programme_choice) { other_programme }

          it { is_expected.to be_other }
          it { is_expected.not_to be_fip }
          it { is_expected.not_to be_cip }
        end
      end
    end

    describe "#allow_change_programme?" do
      context "when CIP" do
        let(:induction_programme_choice) { "core_induction_programme" }

        it "allows changing of induction programme" do
          expect(subject.allow_change_programme?).to be(true)
        end
      end

      context "when FIP" do
        let(:induction_programme_choice) { "full_induction_programme" }

        context "when lead provider is present" do
          it "allows changing of induction programme" do
            expect(subject.allow_change_programme?).to be(false)
          end
        end

        context "when lead provider is nil" do
          before { allow(school_cohort).to receive(:lead_provider).and_return(nil) }

          it "allows changing of induction programme" do
            expect(subject.allow_change_programme?).to be(true)
          end
        end
      end

      context "when other" do
        let(:induction_programme_choice) { "no_early_career_teachers" }

        it "allows changing of induction programme" do
          expect(subject.allow_change_programme?).to be(true)
        end
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
      expect(subject).to have_received(:with_partnership_component).with(school:, school_cohort:, partnership:, training_programme: "Working with a DfE-funded provider")
    end

    it "passes the relationship information to the relationship slots" do
      relationships.each do |relationship|
        expect(subject).to have_received(:with_relationship_component).with(school:, school_cohort:, relationship:, superuser: false)
      end
    end
  end
end
