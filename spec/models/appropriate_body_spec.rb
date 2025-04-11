# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBody, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:appropriate_body_profiles) }
  end

  it "is valid with name and body type" do
    expect(create(:appropriate_body_local_authority)).to be_valid
    expect(create(:appropriate_body_national_organisation)).to be_valid
    expect(create(:appropriate_body_teaching_school_hub)).to be_valid
  end

  it "has name unique per body type" do
    create(:appropriate_body_local_authority, name: "not unique one")
    not_valid_ab = build(:appropriate_body_local_authority, name: "not unique one")
    expect(not_valid_ab).to_not be_valid
  end

  it "updates analytics when a record is created" do
    expect {
      create(:appropriate_body_local_authority)
    }.to have_enqueued_job(Analytics::UpsertECFAppropriateBodyJob)
  end

  it "updates analytics when any attributes changes" do
    appropriate_body = create(:appropriate_body_local_authority)

    expect {
      appropriate_body.update!(name: "Crispy Code")
    }.to have_enqueued_job(Analytics::UpsertECFAppropriateBodyJob).with(appropriate_body_id: appropriate_body.id)
  end

  it "filter appropriate bodies disabled in a given year" do
    create(:appropriate_body_local_authority, name: "from 2022", disable_from_year: 2022)
    create(:appropriate_body_local_authority, name: "from 2021", disable_from_year: 2021)
    create(:appropriate_body_local_authority, name: "enabled", disable_from_year: nil)
    expect(AppropriateBody.count).to eq(3)
    expect(AppropriateBody.active_in_year(2020).count).to eq(3)
    expect(AppropriateBody.active_in_year(2021).count).to eq(2)
    expect(AppropriateBody.active_in_year(2022).count).to eq(1)
  end

  it "filters ABs removed from selection" do
    ab1 = create(:appropriate_body_local_authority, name: "Acting")
    ab2 = create(:appropriate_body_local_authority, name: "No Longer Acting", selectable_by_schools: false)
    ab3 = create(:appropriate_body_local_authority, name: "from 2021", disable_from_year: 2021)
    expect(AppropriateBody.all).to match_array [ab1, ab2, ab3]
    expect(AppropriateBody.selectable_by_schools).to match_array [ab1, ab3]
    expect(AppropriateBody.selectable_by_schools.active_in_year(2022)).to match_array [ab1]
  end
end
