# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Participants::Search do
  let(:search) { Admin::Participants::Search }

  describe "searching" do
    let!(:school) { user_1.school }

    let!(:npq_application) { create(:npq_application, user: user_1) }

    let!(:user_1) do
      create(:user,
             :induction_coordinator,
             full_name: "Andrew Armstrong",
                 email: "aaaa@example.com")
    end
    let!(:user_2) { create(:user, full_name: "Bonnie Benson", email: "bbbb@example.com") }
    let!(:user_3) { create(:user, full_name: "Charles Cross", email: "cccc@example.com") }

    let!(:pp_1) { create(:ect_participant_profile, user: user_1) }
    let!(:pp_2) { create(:ect_participant_profile, user: user_2) }
    let!(:pp_3) { create(:npq_participant_profile, user: user_3) }

    context "when searching with a string" do
      describe "matching by name (case insensitively)" do
        let(:results) { search.call(ParticipantProfile, search_term: "ben") }

        it "returns matching participants" do
          expect(results).to include(pp_2)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_1, pp_3)
        end
      end

      describe "matching by user email (case insensitively)" do
        let(:results) { search.call(ParticipantProfile, search_term: "ccc") }

        it "returns matching participants" do
          expect(results).to include(pp_3)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_1, pp_2)
        end
      end

      describe "matching by participant identity email (case insensitively)" do
        before do
          pp_2.participant_identity.update(email: "dddd@example.com")
        end

        let(:results) { search.call(ParticipantProfile, search_term: "ddd") }

        it "returns matching participants" do
          expect(results).to include(pp_2)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_1, pp_3)
        end
      end

      describe "matching by TRN" do
        before { pp_3.teacher_profile.update(trn: "123456") }

        let(:results) { search.call(ParticipantProfile, search_term: "1234") }

        it "returns matching participants" do
          expect(results).to include(pp_3)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_1, pp_2)
        end
      end

      describe "matching by participant profile id" do
        let(:search_term) { pp_1.id }

        let(:results) { search.call(ParticipantProfile, search_term:) }

        it "returns matching participants" do
          expect(results).to include(pp_1)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_2, pp_3)
        end
      end

      describe "matching by teacher profile id" do
        let(:search_term) { user_2.teacher_profile.id }

        let(:results) { search.call(ParticipantProfile, search_term:) }

        it "returns matching participants" do
          expect(results).to include(pp_2)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_1, pp_3)
        end
      end

      describe "matching by user id" do
        let(:search_term) { user_3.id }

        let(:results) { search.call(ParticipantProfile, search_term:) }

        it "returns matching participants" do
          expect(results).to include(pp_3)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_1, pp_2)
        end
      end

      describe "matching by user id" do
        let(:search_term) { pp_1.participant_identity.external_identifier }

        let(:results) { search.call(ParticipantProfile, search_term:) }

        it "returns matching participants" do
          expect(results).to include(pp_1)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_2, pp_3)
        end
      end

      describe "matching by teacher reference number" do
        let(:search_term) { user_1.npq_applications.first.teacher_reference_number }

        let(:results) { search.call(ParticipantProfile, search_term:) }

        it "returns matching participants" do
          expect(results).to include(pp_1)
        end

        it "doesn't return non-matching participants" do
          expect(results).not_to include(pp_2, pp_3)
        end
      end
    end
  end
end
