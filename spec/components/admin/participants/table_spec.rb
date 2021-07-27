# frozen_string_literal: true

RSpec.describe Admin::Participants::Table, type: :view_component do
  let!(:participant_profiles) { create_list :participant_profile, rand(11..15) }
  let(:page) { rand 1..2 }

  component { described_class.new profiles: ParticipantProfile.all.order(:id), page: page }
  request_path "/admin/participants"

  stub_component Admin::Participants::TableRow

  it "renders table row for each participant profile on this page" do
    expected_profiles = participant_profiles.sort_by(&:id).each_slice(10).to_a[page - 1]

    expected_profiles.each do |profile|
      expect(rendered).to have_rendered(Admin::Participants::TableRow).with(profile: profile)
    end

    (participant_profiles - expected_profiles).each do |other_page_profiles|
      expect(rendered).not_to have_rendered(Admin::Participants::TableRow)
        .with(hash_including(partnership: other_page_profiles))
    end
  end
end
