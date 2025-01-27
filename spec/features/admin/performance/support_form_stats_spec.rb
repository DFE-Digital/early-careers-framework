# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin should be able to visit the support query stats page", js: true, rutabaga: false do
  before { setup_support_queries }

  scenario "I should be able to see the support query stats" do
    given_i_sign_in_as_an_admin_user
    when_i_visit admin_performance_support_queries_path
    then_i_should_see_the_support_query_stats
  end

private

  def when_i_visit(path)
    visit path
  end

  def then_i_should_see_the_support_query_stats
    SupportQuery::VALID_SUBJECTS.each do |subject|
      expect(page).to have_content(I18n.t("support_query.stats.#{subject}"))
    end

    expect(page).to have_content("User visited support form directly 2 1")
    expect(page).to have_content("Change lead provider for a participant 2 2")
    expect(page).to have_content("Change date of birth for a participant 0 0")
    expect(page).to have_content("Change TRN for a participant 0 0")
    expect(page).to have_content("Change lead provider for an academic year 0 0")
    expect(page).to have_content("Change delivery partner for an academic year 0 0")
    expect(page).to have_content("Change training programme choice for an academic year 0 0")
  end

  def setup_support_queries
    user_1 = create(:user)
    user_2 = create(:user)
    create(:user)

    create(:support_query, subject: :unspecified, user: user_1)
    create(:support_query, subject: :unspecified, user: user_1)

    create(:support_query, subject: :"change-participant-lead-provider", user: user_1)
    create(:support_query, subject: :"change-participant-lead-provider", user: user_2)
  end
end
