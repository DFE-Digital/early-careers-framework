# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::Search do
  include ArchiveHelper

  subject(:search) { described_class }

  describe "searching" do
    let(:id1) { SecureRandom.uuid }
    let(:id2) { SecureRandom.uuid }
    let(:id3) { SecureRandom.uuid }
    let(:alt_id1) { SecureRandom.uuid }
    let(:profile_id1) { SecureRandom.uuid }
    let!(:user1) { build_archived_ect(name: "Adam West", id: id1, alt_id: alt_id1, profile_id: profile_id1, trn: "0012345") }
    let!(:user2) { build_archived_ect(name: "Burt Ward", id: id2, trn: "9876543") }
    let!(:user3) { build_archived_ect(name: "Frank Gorshin", id: id3, trn: "0090210") }

    context "when no criteria are specified" do
      let(:results) { search.call(search_term: nil) }

      it "returns all the entries" do
        expect(results).to match_array [user1, user2, user3]
      end
    end

    context "when no matches are found" do
      let(:results) { search.call(search_term: "bananas") }

      it "returns an empty collection" do
        expect(results).to be_empty
      end
    end

    context "when searching with a string" do
      describe "matching by name (case insensitively)" do
        let(:results) { search.call(search_term: "WEST") }

        it "returns matching participants" do
          expect(results).to match_array [user1]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user2, user3)
        end
      end

      describe "matching by user email (case insensitively)" do
        let(:results) { search.call(search_term: "ard@EXAmple") }

        it "returns matching participants" do
          expect(results).to match_array [user2]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user1, user3)
        end
      end

      describe "matching by participant identity email (case insensitively)" do
        let(:results) { search.call(search_term: "frank-gorshin9@gmail.com") }

        it "returns matching participants" do
          expect(results).to match_array [user3]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user1, user2)
        end
      end

      describe "matching by TRN" do
        let(:results) { search.call(search_term: "12345") }

        it "returns matching participants" do
          expect(results).to match_array [user1]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user2, user3)
        end
      end

      describe "matching by participant profile id" do
        let(:results) { search.call(search_term: profile_id1) }

        it "returns matching participants" do
          expect(results).to match_array [user1]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user2, user3)
        end
      end

      describe "matching by user id" do
        let(:results) { search.call(search_term: id3) }

        it "returns matching participants" do
          expect(results).to match_array [user3]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user1, user2)
        end
      end

      describe "matching by external identifier" do
        let(:results) { search.call(search_term: alt_id1) }

        it "returns matching participants" do
          expect(results).to match_array [user1]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user2, user3)
        end
      end

      describe "matching by teacher reference number" do
        let(:search_term) { user_1.npq_applications.first.teacher_reference_number }

        let(:results) { search.call(search_term: "9876543") }

        it "returns matching participants" do
          expect(results).to match_array [user2]
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(user1, user3)
        end
      end
    end
  end
end
