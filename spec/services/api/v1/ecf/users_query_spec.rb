# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECF::UsersQuery, :with_default_schedules do
  let!(:ecf_users) { create_list(:ecf_participant_profile, 3).map(&:user) }
  let!(:non_ecf_user) { create(:npq_participant_profile).user }

  subject { described_class.new.all }

  it "returns a list of users" do
    expect(subject).to all(be_a(User))
  end

  it "only includes ECF participants" do
    expect(subject).to match_array(ecf_users)
    expect(subject).not_to include(non_ecf_user)
  end

  context "when filtering by updated_since" do
    let!(:ecf_user_updated_a_long_time_ago) { create(:ecf_participant_profile).user }

    before { ecf_user_updated_a_long_time_ago.update(updated_at: 1.year.ago) }

    subject { described_class.new(updated_since: 1.month.ago).all }

    it "returns a list of users with updated_at timestamps later than the supplied one" do
      expect(subject).to match_array(ecf_users)
      expect(subject).not_to include(ecf_user_updated_a_long_time_ago)
    end
  end

  context "when filtering by email" do
    let(:target) { ecf_users.first }

    subject { described_class.new(email: target.email).all }

    it "it only returns users with the matching email address" do
      expect(subject).to include(target)
      expect(subject).not_to include(ecf_users.without(target))
    end
  end
end
