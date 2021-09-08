# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing the school dashboard", type: :feature do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.schools.first }
  let(:privacy_policy) { create :privacy_policy }
  let(:cohort) { create(:cohort, start_year: "2021") }

  before do
    privacy_policy.accept!(user)
  end

  context "the school has chosen a programme" do
    let!(:school_cohort) do
      create(
        :school_cohort,
        cohort: cohort,
        school: user.induction_coordinator_profile.schools[0],
      )
    end

    specify "there is a link to the school cohort" do
      sign_in_as user
      visit "/schools/#{school.slug}"

      expect(page).to have_link("2021", href: schools_cohort_path(school_id: school.slug, cohort_id: school_cohort.cohort))
    end
  end

  context "the school has chosen the school funded fip programme" do
    before do
      create(
        :school_cohort,
        cohort: cohort,
        induction_programme_choice: "school_funded_fip",
        school: user.induction_coordinator_profile.schools[0],
      )
    end

    specify "there is not a link to the school cohort" do
      sign_in_as user
      visit "/schools/#{school.slug}"

      expect(page).to_not have_link("2021")
      expect(page).to have_text("2021")
    end
  end
end
