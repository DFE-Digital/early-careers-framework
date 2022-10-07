# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Participants::HistoryBuilder do
  subject { Admin::Participants::HistoryBuilder }
  let!(:profile) do
    induction_record = create(:induction_record)
    induction_record.participant_profile
  end

  let(:mentor) { create :mentor_participant_profile }

  after do
    PaperTrail.enabled = false
  end

  it "should have 5 records when just created" do
    event_list = described_class.from_profile(profile).events
    expect(event_list.count).to eq 5

    descriptions = event_list.map(&:description)

    expect(descriptions).to include "Registered with the system"
    expect(descriptions).to include "Teacher record created"
    expect(descriptions).to include "Identity created"
    expect(descriptions).to include "Participant Profile created"
    expect(descriptions).to include "InductionRecords started"
  end

  it "should have 6 records after a name change" do
    PaperTrail.enabled = true
    profile.user.update! full_name: "Martin Luthor"

    event_list = described_class.from_profile(profile).events
    expect(event_list.count).to eq 6

    descriptions = event_list.map(&:description)

    expect(descriptions).to include "Changed name"
  end

  it "should have 8 records after a name, TRN and Mentor change" do
    PaperTrail.enabled = true
    profile.user.update! full_name: "Martin Luthor"
    profile.user.teacher_profile.update! trn: "0123456"

    Induction::ChangeMentor.call induction_record: profile.induction_records.latest,
                                 mentor_profile: mentor

    event_list = described_class.from_profile(profile).events
    expect(event_list.count).to eq 8

    descriptions = event_list.map(&:description)

    expect(descriptions).to include "Changed name"
    expect(descriptions).to include "TRN updated"
    expect(descriptions).to include "New Mentor assigned"
  end
end
