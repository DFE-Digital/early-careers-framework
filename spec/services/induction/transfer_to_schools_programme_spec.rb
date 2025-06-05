# frozen_string_literal: true

RSpec.describe Induction::TransferToSchoolsProgramme do
  describe "#call" do
    let(:lead_provider_1) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
    let(:lead_provider_2) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
    let(:school_cohort_1) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider_1) }
    let(:school_cohort_2) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider_2) }
    let!(:induction_programme_2) { school_cohort_2.induction_programmes.first }
    let!(:mentor_profile_1) { create(:mentor, school_cohort: school_cohort_1, lead_provider: lead_provider_1) }
    let!(:mentor_profile_2) { create(:mentor, school_cohort: school_cohort_2, lead_provider: lead_provider_2) }
    let(:participant_profile) { create(:ect, school_cohort: school_cohort_1, lead_provider: lead_provider_1, mentor_profile_id: mentor_profile_1.id) }
    let(:start_date) { 1.week.from_now }
    let(:end_date) { 1.week.ago }
    let(:new_email_address) { "peter.bonetti@new-school.example.com" }
    let(:new_induction_programme) { school_cohort_2.induction_programmes.order(:created_at).last }

    subject(:service) { described_class }

    let(:service_call) do
      service.call(participant_profile:,
                   induction_programme: induction_programme_2,
                   email: new_email_address,
                   start_date:,
                   end_date:,
                   mentor_profile: mentor_profile_2)
    end

    let!(:original_induction) { participant_profile.current_induction_record }

    it "creates a new identity with the given email" do
      expect { service_call }.to change { participant_profile.user.participant_identities.count }.by 1
    end

    it "creates an induction record for the new participant" do
      expect { service_call }.to change { induction_programme_2.induction_records.count }.by 1
    end

    it "updates the school cohort and schedule of the participant" do
      service_call

      expect(participant_profile.school_cohort).to eq(induction_programme_2.school_cohort)
      expect(participant_profile.schedule.cohort).to eq(induction_programme_2.cohort)
    end

    context "when the participant is eligible to be moved from a frozen cohort to the target one" do
      let(:school_cohort_2) do
        create(:school_cohort,
               :fip,
               :with_induction_programme,
               cohort: Cohort.next,
               lead_provider: lead_provider_2)
      end

      before do
        allow(participant_profile).to receive(:unfinished_with_billable_declaration?)
                                        .with(cohort: Cohort.next)
                                        .and_return(true)
        create(:ecf_extended_schedule, cohort: Cohort.next)
        service_call
      end

      it "flags the participant as changed for that reason" do
        expect(participant_profile).to be_cohort_changed_after_payments_frozen
      end

      it "sets 'ecf-extended-september' schedule" do
        expect(participant_profile.schedule.schedule_identifier).to eq("ecf-extended-september")
        expect(participant_profile.reload.latest_induction_record.schedule).to eq(participant_profile.schedule)
      end
    end

    context "when the participant is not eligible to be moved from a frozen cohort to the target one" do
      before do
        allow(participant_profile).to receive(:unfinished_with_billable_declaration?)
                                        .with(cohort: school_cohort_2.cohort)
                                        .and_return(false)
        service_call
      end

      it "flag the participant as not changed for that reason" do
        expect(participant_profile).not_to be_cohort_changed_after_payments_frozen
      end
    end

    context "record details" do
      let(:new_induction_record) { participant_profile.induction_records.latest }

      before { service_call }

      it "updates the previous induction record to leaving status" do
        expect(original_induction.reload).to be_leaving_induction_status
        expect(original_induction.end_date).to be_within(1.second).of end_date
      end

      it "enrols the participant in the new programme" do
        expect(new_induction_record.induction_programme).to eq new_induction_programme
        expect(new_induction_record).to be_active_induction_status
        expect(new_induction_record.start_date).to be_within(1.second).of start_date
        expect(new_induction_record.schedule.cohort).to eq(new_induction_programme.cohort)
      end

      it "assigns the specified mentor to the induction" do
        expect(new_induction_record.mentor_profile).to eq mentor_profile_2
      end

      it "assigns the preferred_identity to the induction" do
        expect(new_induction_record.preferred_identity.email).to eq new_email_address
      end
    end

    context "when an ECT in a non-frozen cohort is transferred and mentor is in a frozen one" do
      let(:frozen_cohort) { Cohort.find_by_start_year(2021) || create(:cohort, start_year: 2021) }
      let(:mentor_school_cohort) do
        NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort: frozen_cohort).build.with_programme.school_cohort
      end

      let!(:mentor_profile_2) do
        NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
          .new(school_cohort: mentor_school_cohort)
          .build
          .with_induction_record(induction_programme: mentor_school_cohort.default_induction_programme)
          .participant_profile
      end

      before do
        frozen_cohort.update!(payments_frozen_at: 1.month.ago)
      end

      it "don't move the mentor from their cohort", with_feature_flags: { closing_2022: "active" } do
        expect { service_call }
          .not_to change { mentor_profile_2.reload.schedule.cohort.start_year }
      end

      it "moves the mentor to the currently active registration cohort", mid_cohort: true do
        expect { service_call }
          .to change { mentor_profile_2.reload.schedule.cohort.start_year }
                .from(2021)
                .to(Cohort.active_registration_cohort.start_year)
      end
    end

    context "without optional params" do
      let(:new_induction_record) { participant_profile.current_induction_record }
      before do
        service.call(participant_profile:, induction_programme: induction_programme_2)
      end

      it "uses the existing participant identity" do
        expect(new_induction_record.preferred_identity).to eq participant_profile.participant_identity
      end

      it "sets the start date on the new induction as the current time" do
        expect(new_induction_record.start_date).to be_within(1.second).of Time.zone.now
      end

      it "sets the end date on the previous induction as the current time" do
        expect(original_induction.reload.end_date).to be_within(1.second).of Time.zone.now
      end
    end

    context "when the participant is a mentor" do
      before do
        Mentors::AddToSchool.call(mentor_profile: mentor_profile_1, school: school_cohort_1.school)
      end

      it "calls the Mentors::ChangeSchool service" do
        expect(Mentors::ChangeSchool).to receive(:call).with(mentor_profile: mentor_profile_1,
                                                             from_school: school_cohort_1.school,
                                                             to_school: school_cohort_2.school,
                                                             remove_on_date: start_date,
                                                             preferred_email: new_email_address)

        service.call(participant_profile: mentor_profile_1,
                     induction_programme: induction_programme_2,
                     email: new_email_address,
                     start_date:,
                     end_date:)
      end
    end
  end
end
