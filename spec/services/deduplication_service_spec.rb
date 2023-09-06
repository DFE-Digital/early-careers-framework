# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeduplicationService do
  let(:user) { create(:user, email: "user@example.org") }
  let(:deletable_user) { create(:teacher_profile, user:).user }
  let(:admin_user) { create(:user, :admin) }
  let(:appropriate_body_user) { create(:user, :appropriate_body) }
  let(:delivery_partner_user) { create(:user, :delivery_partner) }
  let(:finance_user) { create(:user, :finance) }
  let(:induction_coordinator_user) { create(:user, :induction_coordinator) }
  let(:lead_provider_user) { create(:user, :lead_provider) }

  before do
    deletable_user

    admin_user
    appropriate_body_user
    delivery_partner_user
    finance_user
    induction_coordinator_user
    lead_provider_user
  end

  describe ".select_users_to_archive" do
    let(:users_to_delete) { DeduplicationService.select_users_to_archive }

    it "does not include admin user" do
      expect(users_to_delete).not_to include(admin_user)
    end

    it "does not include appropriate body user" do
      expect(users_to_delete).not_to include(appropriate_body_user)
    end

    it "does not include delivery partner user" do
      expect(users_to_delete).not_to include(delivery_partner_user)
    end

    it "does not include finance user" do
      expect(users_to_delete).not_to include(finance_user)
    end

    it "does not include induction coordinator user" do
      expect(users_to_delete).not_to include(induction_coordinator_user)
    end

    it "does not include lead provider user" do
      expect(users_to_delete).not_to include(lead_provider_user)
    end

    it "includes deletable" do
      expect(users_to_delete).to include(deletable_user)
    end
  end

  describe ".dedup_users" do
    it "performs deduplication (archiving) users" do
      expect { DeduplicationService.dedup_users! }.to change { deletable_user.reload.email }.from("user@example.org").to("user#{deletable_user.id}@example.org")
    end
  end
end
