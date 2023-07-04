# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ChangeRelationship do
  let(:cohort) { create(:seed_cohort) }
  let(:schedule) { create(:seed_finance_schedule, cohort:) }
  let(:participant_profile) { create(:ect_participant_profile, schedule:) }

  let(:old_induction_programme) { setup_school_programme(prefix: "Old", cohort:) }
  let(:current_induction_programme) { setup_school_programme(prefix: "Current", cohort:) }

  let!(:old_induction_record) do
    create(:seed_induction_record,
           :leaving,
           participant_profile:,
           schedule:,
           induction_programme: old_induction_programme)
  end

  let!(:current_induction_record) do
    create(:seed_induction_record,
           participant_profile:,
           schedule:,
           school_transfer:,
           induction_programme: current_induction_programme)
  end

  let(:current_school_cohort) { current_induction_programme.school_cohort }
  let(:current_school) { current_school_cohort.school }

  let(:new_provider) { create(:seed_lead_provider, :with_cpd_lead_provider, name: "New Provider") }
  let!(:new_partnership) do
    create(:seed_partnership,
           :with_delivery_partner,
           cohort:,
           school: current_school,
           lead_provider: new_provider)
  end

  let!(:new_induction_programme) do
    create(:seed_induction_programme,
           :fip,
           partnership: new_partnership,
           school_cohort: current_school_cohort)
  end

  let(:school_transfer) { true }
  let(:fixing_mistake) { false }

  subject(:service_call) { described_class.call(induction_record: current_induction_record, partnership: new_partnership, fixing_mistake:) }

  describe "#call" do
    context "when correcting a mistake" do
      let(:fixing_mistake) { true }

      context "updates to the existing induction record" do
        before do
          service_call
        end

        it "changes the induction programme" do
          expect(current_induction_record.induction_programme).to eq new_induction_programme
          expect(current_induction_record.lead_provider_name).to eq "New Provider"
        end

        it "retains the transfer flag state" do
          expect(current_induction_record).to be_school_transfer
        end

        it "does not update the induction status" do
          expect(current_induction_record).to be_active_induction_status
        end

        context "when the transfer flag is not set" do
          let(:school_transfer) { false }

          it "retains the transfer flag state" do
            expect(current_induction_record).not_to be_school_transfer
          end
        end
      end

      context "when the participant has declarations from the current provider" do
        let(:user) { participant_profile.user }
        let(:cpd_lead_provider) { current_induction_record.lead_provider.cpd_lead_provider }
        let!(:declaration) { create(:seed_ecf_participant_declaration, participant_profile:, user:, cpd_lead_provider:) }

        it "raises an error" do
          expect {
            service_call
          }.to raise_error ArgumentError, "Participant has declarations with current provider!"
        end
      end

      context "handling the old programme" do
        it "does not remove the old programme" do
          expect {
            service_call
          }.not_to change { InductionProgramme.count }
        end

        context "when the old programme is not the cohort default and has a relationship partnership and no other induction records" do
          let(:relationship) { true }

          let(:another_programme) do
            create(:seed_induction_programme, :fip, partnership: another_partnership, school_cohort: current_school_cohort)
          end

          let!(:current_induction_record) do
            create(:seed_induction_record,
                   participant_profile:,
                   schedule:,
                   school_transfer:,
                   induction_programme: another_programme)
          end

          let(:another_partnership) do
            create(:seed_partnership,
                   :with_lead_provider,
                   :with_delivery_partner,
                   cohort:,
                   school: current_school_cohort.school,
                   relationship:)
          end

          it "removes the old programme" do
            expect {
              service_call
            }.to change { InductionProgramme.count }.by(-1)
          end

          context "when the old programme partnership is not a relationship" do
            let(:relationship) { false }

            it "does not remove the old programme" do
              expect {
                service_call
              }.not_to change { InductionProgramme.count }
            end
          end

          context "when other induction records are associated with the old programme" do
            let!(:other_induction_record) { create(:seed_induction_record, :valid, induction_programme: another_programme) }

            it "does not remove the old programme" do
              expect {
                service_call
              }.not_to change { InductionProgramme.count }
            end
          end
        end
      end
    end

    context "when changing circumstances" do
      it "adds a new induction record" do
        expect {
          service_call
        }.to change { InductionRecord.count }.by(1)
      end

      context "existing induction record changes" do
        before do
          service_call
        end

        it "sets the current induction reacord as changed" do
          expect(current_induction_record).to be_changed_induction_status
        end

        it "sets an end date" do
          expect(current_induction_record.end_date).to be_within(2.seconds).of(Time.zone.now)
        end

        it "does not change the programme" do
          expect(current_induction_record.induction_programme).to eql current_induction_programme
        end

        it "does not change the provider" do
          expect(current_induction_record.lead_provider_name).to eql "Current Provider"
        end
      end

      context "new induction record" do
        before do
          service_call
          @new_induction_record = participant_profile.current_induction_record
        end

        it "changes the induction programme" do
          expect(@new_induction_record.induction_programme).to eq new_induction_programme
        end

        it "changes the provider" do
          expect(@new_induction_record.lead_provider_name).to eq "New Provider"
        end

        it "does not retain the transfer flag state" do
          expect(@new_induction_record).not_to be_school_transfer
        end

        it "sets the start date" do
          expect(@new_induction_record.start_date).to be_within(2.seconds).of(Time.zone.now)
        end

        it "has active induction status" do
          expect(@new_induction_record).to be_active_induction_status
        end
      end
    end

    context "when an induction programme for the requested partnership does not exist" do
      let!(:new_induction_programme) { nil }

      it "creates a new induction programme to support it" do
        expect {
          service_call
        }.to change { InductionProgramme.count }.by(1)
      end
    end

    context "checking the partnership is suitable" do
      let(:other_cohort) { create(:seed_cohort, start_year: cohort.start_year + 1) }

      context "when the partnership is for a different cohort" do
        let!(:new_partnership) do
          create(:seed_partnership, :with_delivery_partner, cohort: other_cohort, school: current_school, lead_provider: new_provider)
        end

        it "raises an ArgumentError" do
          expect {
            service_call
          }.to raise_error ArgumentError, "This partnership is in a different cohort!"
        end
      end

      context "when the partnership has been challenged" do
        let!(:new_partnership) do
          create(:seed_partnership, :with_delivery_partner, :challenged, cohort:, school: current_school, lead_provider: new_provider)
        end

        it "raises an ArgumentError" do
          expect {
            service_call
          }.to raise_error ArgumentError, "This partnership has been challenged!"
        end
      end
    end
  end

  def setup_school_programme(prefix:, cohort:)
    school_cohort = create(:seed_school_cohort, :fip, :with_school, cohort:)
    school = school_cohort.school
    cpd_lead_provider = create(:seed_cpd_lead_provider, name: "#{prefix} CPD Provider")
    provider = create(:seed_lead_provider, cpd_lead_provider:, name: "#{prefix} Provider")
    partnership = create(:seed_partnership,
                         :with_delivery_partner,
                         cohort:,
                         school:,
                         lead_provider: provider)

    induction_programme = create(:seed_induction_programme,
                                 :fip,
                                 partnership:,
                                 school_cohort:)

    school_cohort.update!(default_induction_programme: induction_programme)

    induction_programme
  end
end
