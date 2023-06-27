# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersQuery do
  let!(:users) { create_list(:user, 3) }
  let(:updated_since) { nil }
  let(:email) { nil }

  subject { described_class.new(updated_since:, email:) }

  describe "#all" do
    it "returns a list of users" do
      expect(subject.all).to all(be_a(User))
      expect(subject.all).to match_array(users)
    end

    context "when filtering by updated_since" do
      let!(:user_updated_a_long_time_ago) { create(:user, updated_at: 1.year.ago) }
      let(:updated_since) { 1.month.ago }

      it "returns a list of users with updated_at timestamps later than the supplied one" do
        expect(subject.all).to match_array(users)
        expect(subject.all).not_to include(user_updated_a_long_time_ago)
      end
    end

    context "when filtering by email" do
      context "with a matching email address" do
        let(:email) { users.last.email }

        it "only returns the user record" do
          expect(subject.all).to include(users.last)
          expect(subject.all).not_to include(users.without(users.last))
        end
      end

      context "with no matching email address" do
        let(:email) { "dontexist@anyexample.com" }

        it "returns no users" do
          expect(subject.all).to be_empty
        end
      end
    end

    context "when filtering by identity record email" do
      let(:user) { create(:user, email: "fred@anyexample.com") }
      let!(:identity) { create(:participant_identity, user:, email: "charlie@anyexample.com") }

      context "when a matching identity record exists" do
        let(:email) { "charlie@anyexample.com" }

        it "returns the associated user record" do
          expect(subject.all.size).to eql(1)
          expect(subject.all.first.email).to eql("fred@anyexample.com")
        end
      end

      context "when a matching user record exists" do
        let(:email) { "fred@anyexample.com" }

        it "returns the user record" do
          expect(subject.all.size).to eql(1)
          expect(subject.all.first.email).to eql("fred@anyexample.com")
        end
      end

      context "when a matching identity or user record is not found" do
        let(:email) { "arthur@anyexample.com" }

        it "returns no users" do
          expect(subject.all).to be_empty
        end
      end
    end
  end
end
