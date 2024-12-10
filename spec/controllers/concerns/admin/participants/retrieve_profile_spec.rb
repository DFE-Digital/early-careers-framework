# frozen_string_literal: true

require "rails_helper"

class RetrieveProfileTestsController < Admin::BaseController
  include Admin::Participants::RetrieveProfile
end

describe Admin::Participants::RetrieveProfile, type: :controller do
  let(:user) { create(:user, :admin) }
  let!(:ect_participant_profile) { create(:ect_participant_profile) }
  let!(:mentor_participant_profile) { create(:mentor_participant_profile) }

  controller RetrieveProfileTestsController do
    def index
      render body: @participant_profile.id
    end
  end

  before do
    sign_in user

    routes.append do
      get "index" => "retrieve_profile_tests#index"
    end
  end

  it "returns correct data" do
    params = { participant_id: ect_participant_profile.id }
    response = get("index", params:)

    expect(response.body).to eq(ect_participant_profile.id)
  end

  context "when participant id is not in the params" do
    it "raises an error" do
      params = { any: "1" }

      expect { get("index", params:) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when participant is an ECT participant" do
    it "returns correct data" do
      params = { participant_id: ect_participant_profile.id }
      response = get("index", params:)

      expect(response.body).to eq(ect_participant_profile.id)
    end
  end

  context "when participant is a Mentor participant" do
    it "returns correct data" do
      params = { participant_id: mentor_participant_profile.id }
      response = get("index", params:)

      expect(response.body).to eq(mentor_participant_profile.id)
    end
  end

  context "when participant does not exist" do
    it "raises an error" do
      params = { participant_id: "1" }

      expect { get("index", params:) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
