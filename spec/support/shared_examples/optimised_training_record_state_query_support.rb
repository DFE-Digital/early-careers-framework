# frozen_string_literal: true

shared_examples "a query optimised for calculating training record states" do |email_optimization: true, mentor_optimization: true|
  describe "#induction_records" do
    if email_optimization
      context "when there is an email associated with the participant that has a request_for_details tag" do
        before { create(:email, associated_with: [participant_profile], tags: %w[request_for_details]) }

        it "populates transient_latest_request_for_details_status with the email status" do
          expect(subject.induction_records.last).to have_attributes(transient_latest_request_for_details_status: "submitted")
        end
      end
    end

    if mentor_optimization
      context "when there are historical mentees associated with the participant" do
        let(:participant_profile) { create(:mentor) }
        let!(:mentee) { create(:ect, mentor_profile: participant_profile) }

        before { mentee.latest_induction_record.update!(induction_status: "completed") }

        it "populates transient_mentees with true" do
          expect(subject.induction_records.last).to have_attributes(transient_mentees: true)
          expect(subject.induction_records.last).to have_attributes(transient_current_mentees: false)
        end
      end

      context "when there are mentees associated with the participant that are leaving" do
        let(:participant_profile) { create(:mentor) }
        let!(:mentee) { create(:ect, mentor_profile: participant_profile) }

        before { mentee.latest_induction_record.update!(induction_status: "leaving", end_date: 1.week.from_now) }

        it "populates transient_current_mentees with true" do
          expect(subject.induction_records.last).to have_attributes(transient_mentees: true)
          expect(subject.induction_records.last).to have_attributes(transient_current_mentees: true)
        end
      end

      context "when there are mentees associated with the participant that have left" do
        let(:participant_profile) { create(:mentor) }
        let!(:mentee) { create(:ect, mentor_profile: participant_profile) }

        before { mentee.latest_induction_record.update!(induction_status: "leaving", end_date: 1.week.ago) }

        it "populates transient_mentees with true" do
          expect(subject.induction_records.last).to have_attributes(transient_mentees: true)
          expect(subject.induction_records.last).to have_attributes(transient_current_mentees: false)
        end
      end

      context "when there are current mentees associated with the participant" do
        let(:participant_profile) { create(:mentor) }
        let!(:mentee) { create(:ect, mentor_profile: participant_profile) }

        it "populates transient_current_mentees with true" do
          expect(subject.induction_records.last).to have_attributes(transient_current_mentees: true)
          expect(subject.induction_records.last).to have_attributes(transient_mentees: true)
        end
      end
    end
  end
end
