# frozen_string_literal: true

RSpec.describe Admin::Participants::Table, :with_default_schedules, type: :component do
  let!(:participant_profiles) { create_list :ecf_participant_profile, rand(11..15) }
  let(:page) { rand 1..2 }

  let(:component) { described_class.new profiles: ParticipantProfile.all.order(:id), page: }
  subject! { render_inline(component) }

  it "renders table row for each participant profile on this page" do
    expected_profiles = participant_profiles.sort_by(&:id).each_slice(10).to_a[page - 1]
    other_page_profiles = participant_profiles - expected_profiles

    expect(rendered_content).to have_css(".govuk-table__body > tr.govuk-table__row", count: expected_profiles.size)
    expect(rendered_content).not_to include(*other_page_profiles.map(&:teacher_profile).map(&:trn))
  end
end
