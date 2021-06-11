# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStudio::SchoolRolloutSerializer do
  describe "serialization" do
    let(:school) { create(:school, urn: "909090", name: "Serial School") }
    let(:nomination_email) { create(:nomination_email, school: school, opened_at: 1.day.ago, notify_status: "sent") }
    let(:tutor) { create(:induction_coordinator_profile, schools: [school]).user }

    it "outputs correctly formatted serialized school rollout data" do
      expected_data = {
        "data" => [
          {
            "id" => school.id,
            "type" => "school_rollout",
            "attributes" => {
              "urn" => school.urn,
              "name" => school.name,
              "sent_at" => nomination_email.sent_at,
              "opened_at" => nomination_email.opened_at,
              "notify_status" => nomination_email.notify_status,
              "induction_tutor_nominated" => true,
              "tutor_nominated_time" => tutor.induction_coordinator_profile.created_at,
              "induction_tutor_signed_in" => tutor.current_sign_in_at.present?,
              "induction_programme_choice" => nil,
              "programme_chosen_time" => nil,
              "in_partnership" => false,
              "partnership_time" => nil,
            },
          },
        ],
      }.to_json

      school_data = DataStudio::FetchSchoolRolloutData.call
      serialized_data = DataStudio::SchoolRolloutSerializer.new(school_data).serializable_hash.to_json
      expect(serialized_data).to eq expected_data
    end
  end
end
