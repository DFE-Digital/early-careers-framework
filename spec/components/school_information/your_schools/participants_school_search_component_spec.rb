# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::SchoolInformation::YourSchools::ParticipantsSchoolSearchComponent, type: :component do
  let(:cohort_1) { create(:cohort, start_year: 2021) }
  let(:cohort_2) { create(:cohort, start_year: 2022) }
  let(:school_1) { create(:school) }
  let(:school_2) { create(:school) }
  let(:lead_provider) { create(:lead_provider, cohorts: [cohort_1, cohort_2]) }
  let(:schools) { school_search_form.find_schools(nil) }
  let(:selected_cohort) { cohort_1 }
  let(:component) { described_class.new(schools: schools, selected_cohort: cohort_1, school_search_form: school_search_form) }
  let(:rendered_component) { render_inline(component).to_html }
  let(:partnership_1) { create(:partnership, cohort: cohort_1, school: school_1, lead_provider: lead_provider) }
  let(:partnership_2) { create(:partnership, cohort: cohort_1, school: school_2, lead_provider: lead_provider) }

  let(:school_search_form) do
    search_form = SchoolSearchForm.new
    search_form.cohort_year = cohort_1.start_year
    search_form.lead_provider_id = lead_provider.id
    search_form.with_school_partnerships = true
    search_form
  end

  it "contains Search your schools text" do
    expect(rendered_component).to include "Search your schools<"
  end

  it "contains hidden input field for cohort year in the form" do
    expect(rendered_component).to include ['<input value="', cohort_1.start_year, '" type="hidden" name="school_search_form[cohort_year]" id="school_search_form_cohort_year">'].join
  end

  it "contains hidden input field for selected_cohort_id" do
    expect(rendered_component).to include ['<input value="', cohort_1.id, '" type="hidden" name="school_search_form[selected_cohort_id]" id="school_search_form_selected_cohort_id">'].join
  end

  context "with partnerships" do
    before(:each) do
      partnership_1
      partnership_2
    end

    it "includes both school names in the table" do
      expect(rendered_component).to include school_1.name.to_s
      expect(rendered_component).to include school_2.name.to_s
    end

    it "contains correct links for both schools" do
      expect(rendered_component).to include lead_providers_school_detail_path(school_1.id, selected_cohort_id: selected_cohort.id)
      expect(rendered_component).to include lead_providers_school_detail_path(school_2.id, selected_cohort_id: selected_cohort.id)
    end
  end

  context "without partnerships" do
    it "contains There are currently no partnered schools text" do
      expect(rendered_component).to include "There are currently no partnered schools"
    end
  end
end
