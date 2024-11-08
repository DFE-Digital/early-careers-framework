# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::CheckAndSetCompletionDate do
  let(:cohort) { Cohort.previous || create(:cohort, :previous) }
  let(:school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_fip_and_partnered_in(cohort:)
      .school
  end
  let(:school_cohort) { school.school_cohorts.first }
  let(:induction_programme) { school_cohort.default_induction_programme }
  let(:participant_profile) do
    NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
                                                .build
                                                .with_induction_record(induction_programme:)
                                                .participant_profile
  end
  let(:trn) { participant_profile.trn }
  let(:completion_date) { 1.month.ago.to_date }
  let(:dqt_start_date) { cohort.academic_year_start_date.to_date }
  let(:induction_status) { "active" }
  let(:dqt_induction_record) do
    { "endDate" => completion_date,
      "periods" => [
        { "startDate" => dqt_start_date,
          "endDate" => dqt_start_date + 2.years - 3.months },
        { "startDate" => dqt_start_date + 2.years - 3.months,
          "endDate" => dqt_start_date + 2.years - 1.day },
      ],
      "status" => induction_status }
  end

  subject(:service_call) { described_class.call(participant_profile:) }

  describe "#call" do
    before do
      inside_registration_window(cohort: Cohort.current) do
        allow(DQT::GetInductionRecord).to receive(:call).with(trn:).and_return(dqt_induction_record)
      end
    end

    context "when the participant already have a completion date" do
      let(:induction_completion_date) { 2.months.ago.to_date }

      before do
        participant_profile.update!(induction_completion_date:)
        service_call
      end

      it "do not re-complete the participant" do
        expect(participant_profile.induction_completion_date).to eq induction_completion_date
      end
    end

    context "when DQT provides a completion date" do
      it "complete the participant with the latest induction period" do
        service_call
        expect(participant_profile.induction_completion_date).to eq(dqt_start_date + 2.years - 1.day)
      end
    end

    context "when DQT does not provide a completion date" do
      let(:completion_date) {}

      it "does not set a completion date" do
        service_call
        expect(participant_profile.induction_completion_date).to be_nil
      end
    end

    context "when the participant is not an ECT" do
      let(:participant_profile) { create(:seed_mentor_participant_profile, :valid) }

      it "does not set a completion date" do
        service_call
        expect(participant_profile.induction_completion_date).to be_nil
      end
    end

    context "when cohort sync with dqt induction start date fails" do
      let(:dqt_start_date) { Cohort.current.academic_year_start_date.to_date }

      it "does not change the cohort of the participant" do
        expect { service_call }.not_to change { participant_profile.schedule.cohort }
      end
    end

    context "when cohort sync with dqt induction start date succeeds" do
      context "when the synced cohort is payments-frozen" do
        before do
          cohort.update!(payments_frozen_at: Date.yesterday)
          NewSeeds::Scenarios::SchoolCohorts::Fip
            .new(school:, cohort: Cohort.active_registration_cohort)
            .build
            .with_programme
        end

        context "when the ect induction is not in progress" do
          before do
            allow(participant_profile).to receive(:unfinished_with_billable_declaration?).and_return(true)
          end

          it "leave the participant in the synced cohort" do
            expect { service_call }.not_to change { participant_profile.schedule.cohort }
          end
        end

        context "when the ect induction is in progress" do
          let(:induction_status) { "InProgress" }
          let(:completion_date) {}

          let!(:esp) { create(:appropriate_body, :esp) }
          let!(:istip) { create(:appropriate_body, :istip) }

          context "when the participant is has not ESP or ISTIP appropriate body" do
            it "sit the participant in the active registration cohort" do
              expect { service_call }.to change { participant_profile.schedule.cohort }
                                           .from(cohort)
                                           .to(Cohort.active_registration_cohort)
            end
          end

          context "when the participant has ESP as appropriate body" do
            before do
              participant_profile.latest_induction_record.update!(appropriate_body: esp)
            end

            it "do not sit the participant in the active registration cohort" do
              expect { service_call }.not_to change { participant_profile.schedule.cohort }
            end
          end

          context "when the participant has ISTIP as appropriate body" do
            before do
              participant_profile.latest_induction_record.update!(appropriate_body: istip)
            end

            it "do not sit the participant in the active registration cohort" do
              expect { service_call }.not_to change { participant_profile.schedule.cohort }
            end
          end
        end
      end

      # rubocop:disable Rails/SaveBang
      context "when the synced cohort is not payments-frozen" do
        before do
          NewSeeds::Scenarios::SchoolCohorts::Fip
            .new(school:, cohort: cohort.previous)
            .build
            .with_programme
          Induction::AmendParticipantCohort.new(participant_profile:,
                                                source_cohort_start_year: cohort.start_year,
                                                target_cohort_start_year: cohort.previous.start_year)
                                           .save
        end

        it "leave the participant in the synced cohort" do
          expect { service_call }.to change { participant_profile.schedule.cohort }
                                       .from(cohort.previous)
                                       .to(cohort)
        end
      end
      # rubocop:enable Rails/SaveBang
    end

    context "when completion dates are matching" do
      it "does not record inconsistencies" do
        expect { service_call }.not_to change { ParticipantProfileCompletionDateInconsistency.count }.from(0)
      end
    end

    context "when completion dates are not matching" do
      let(:induction_completion_date) { 2.months.from_now.to_date }

      before do
        participant_profile.update!(induction_completion_date:)
      end

      it "records inconsistency" do
        expect { service_call }.to change { ParticipantProfileCompletionDateInconsistency.count }.from(0).to(1)
      end

      context "when same inconsistency is processed twice" do
        it "records only one inconsistency" do
          expect {
            service_call
            service_call
          }.to change { ParticipantProfileCompletionDateInconsistency.count }.from(0).to(1)
        end
      end
    end
  end
end
