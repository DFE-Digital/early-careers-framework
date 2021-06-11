# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStudio::FetchSchoolRolloutData do
  let!(:schools) { create_list(:school, 3) }

  describe ".call" do
    it "returns the school rollout data" do
      result = described_class.call
      expect(result.count(:all)).to eq schools.size
    end

    it "has populated the school records with additional attributes" do
      result = described_class.call
      school_data = result.first

      school_rollout_attributes.each do |attr|
        expect(school_data).to respond_to attr
      end
    end
  end

  def school_rollout_attributes
    %i[urn name sent_at opened_at notify_status tutor_nominated_time induction_tutor_signed_in induction_programme_choice programme_chosen_time partnership_time]
  end
end
