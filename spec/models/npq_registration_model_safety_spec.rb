# frozen_string_literal: true

require "rails_helper"

describe "NPQ model safety nets", type: :model do
  let(:create_npq_registration_user) { Migration::NPQRegistration::User.create!(email: "test@user.com") }

  describe "write protection" do
    %w[production staging sandbox test review].each do |read_only_env|
      it "prevents writes in the #{read_only_env} environment" do
        allow(Rails).to receive(:env) { read_only_env.inquiry }
        expect { create_npq_registration_user }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end

    %w[development].each do |write_env|
      it "allows writing in the #{write_env} environment" do
        allow(Rails).to receive(:env) { write_env.inquiry }
        expect { create_npq_registration_user }.to change(Migration::NPQRegistration::User, :count).by(1)
      end
    end
  end

  describe "analytics protection" do
    it "does not send DFE Analytics entity events" do
      allow(Rails).to receive(:env) { "development".inquiry }
      create_npq_registration_user
      expect(:create_entity).not_to have_been_enqueued_as_analytics_events
    end
  end
end
