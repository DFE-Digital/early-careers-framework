# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStage::ProcessSchoolChanges do
  subject(:service) { described_class }
  let(:local_authority) { create(:local_authority, code: 10) }
  let(:local_authority_district) { create(:local_authority_district, code: "E123") }
  let!(:staged_school) { create(:staged_school, urn: 20_001, name: "The Starship Children's Centre", la_code: local_authority.code, administrative_district_code: local_authority_district.code, ukprn: "987654321") }
  let(:excluded_attrs) { %w[id created_at updated_at slug network_id domains la_code] }

  describe ".call" do
    context "when the change contains unhandled attributes" do
      let!(:school_change) { create(:staged_school_change, :with_unhandled_changes, school: staged_school) }

      context "when the live school does not exist" do
        it "creates the school" do
          expect { service.call }.to change { ::School.count }.by(1)
        end

        it "links the new school to the correct local authority and district" do
          service.call
          live_school = ::School.find_by(urn: staged_school.urn)
          expect(live_school.local_authority).to eq local_authority
          expect(live_school.local_authority_district).to eq local_authority_district
        end

        it "marks the change as handled" do
          service.call
          expect(school_change.reload).to be_handled
        end
      end

      context "when the live school already exists" do
        let!(:live_school) { create(:school, urn: 20_001, name: "The Starship Children's Centre", school_status_code: 4, school_status_name: "Proposed to open", ukprn: "12345678") }

        it "does not process any of the changes" do
          service.call
          expect(live_school.reload.school_status_code).to eq 4
          expect(live_school.reload.school_status_name).to eq "proposed_to_open"
        end

        it "does not mark the change as handled" do
          service.call
          expect(school_change.reload).not_to be_handled
        end

        context "when the unhandled attributes are not set" do
          before do
            live_school.update!(ukprn: nil)
            service.call
            live_school.reload
          end

          it "syncs the changes to the live school" do
            expect(live_school.school_status_code).to eq 1
            expect(live_school.school_status_name).to eq "open"
            expect(live_school.ukprn).to eq "987654321"
          end

          it "marks the change as handled" do
            service.call
            expect(school_change.reload).to be_handled
          end
        end
      end
    end

    context "when a school status code changes to an open status" do
      let!(:school_change) { create(:staged_school_change, :opening, school: staged_school) }

      context "when the live school does not exist" do
        it "creates a new school" do
          expect { service.call }.to change { ::School.count }.by 1
        end

        it "populates the new school with the staged school attributes" do
          service.call
          live_school = ::School.find_by(urn: staged_school.urn)
          live_attrs = live_school.attributes.except(*excluded_attrs)
          staged_attrs = staged_school.attributes.except(*excluded_attrs)
          expect(live_attrs).to eq staged_attrs
        end

        it "links the new school to the correct local authority and district" do
          service.call
          live_school = ::School.find_by(urn: staged_school.urn)
          expect(live_school.local_authority).to eq local_authority
          expect(live_school.local_authority_district).to eq local_authority_district
        end
      end

      context "when the live school already exists" do
        let!(:live_school) { create(:school, urn: 20_001, name: "The Starship Children's Centre", school_status_code: 4, school_status_name: "Proposed to open") }

        it "does not create a new school" do
          expect { service.call }.not_to change { ::School.count }
        end

        it "updates the live school attributes from the staged school" do
          service.call
          live_attrs = live_school.reload.attributes.except(*excluded_attrs)
          staged_attrs = staged_school.attributes.except(*excluded_attrs)
          expect(live_attrs).to eq staged_attrs
        end
      end

      it "marks the change as handled" do
        service.call
        expect(school_change.reload).to be_handled
      end
    end

    context "when a school status code changes to closed" do
      let!(:school_change) { create(:staged_school_change, :closing, school: staged_school) }
      before do
        staged_school.update!(school_status_code: 2, school_status_name: "closed")
      end

      context "when the live school does not exist" do
        it "does not create a new school" do
          expect(staged_school.counterpart).to be_nil
          expect { service.call }.not_to change { ::School.count }
        end
      end

      context "when a counterpart school exists" do
        let!(:live_school) { create(:school, urn: 20_001, name: "The Starship Children's Centre", school_status_code: 3, school_status_name: "proposed_to_close") }

        context "when no links are present" do
          it "syncs the closed status" do
            service.call
            expect(live_school.reload.school_status_code).to eq 2
            expect(live_school).to be_closed_status
          end

          it "marks the change as handled" do
            service.call
            expect(school_change.reload).to be_handled
          end

          context "when a school_cohort is present" do
            let!(:school_cohort) { create(:school_cohort, :fip, school: live_school) }

            it "does not update the counterpart school" do
              service.call
              expect(live_school.reload.school_status_code).to eq 3
              expect(live_school).to be_proposed_to_close_status
            end

            it "does not mark the change as handled" do
              service.call
              expect(school_change.reload).not_to be_handled
            end
          end

          context "when an induction coordinator is present" do
            let!(:induction_tutor) { create(:induction_coordinator_profile, schools: [live_school]) }

            it "does not update the counterpart school" do
              service.call
              expect(live_school.reload.school_status_code).to eq 3
              expect(live_school).to be_proposed_to_close_status
            end

            it "does not mark the change as handled" do
              service.call
              expect(school_change.reload).not_to be_handled
            end
          end
        end

        context "when a successor school exists" do
          let(:successor_school) { create(:school, urn: 10_001, name: "Starship Juniors School") }
          let!(:staged_successor_school) { create(:staged_school, urn: 10_001, name: "Starship Juniors School", la_code: local_authority.code, administrative_district_code: local_authority_district.code, ukprn: "22334455") }
          let(:school_cohort) { create(:school_cohort, :fip, school: live_school) }
          let!(:induction_tutor) { create(:induction_coordinator_profile, schools: [live_school]) }
          let!(:participants) { create_list(:ecf_participant_profile, 2, school_cohort:) }
          let!(:partnership) { create(:partnership, school: live_school, cohort: school_cohort.cohort) }
          let!(:school_link) { create(:staged_school_link, :successor, school: staged_school, link_urn: successor_school.urn) }

          it "migrates the assets of the school to the successor" do
            service.call
            successor_school.reload
            expect(successor_school.partnerships).to match_array [partnership]
            expect(successor_school.school_cohorts).to match_array [school_cohort]

            participants.each do |participant|
              expect(participant.reload.teacher_profile.school).to eq successor_school
            end

            expect(induction_tutor.reload.schools).to match_array [successor_school]
          end

          it "adds a successor school link" do
            expect { service.call }.to change { SchoolLink.successor.count }.by(1)
          end

          it "adds a predecessor school link" do
            expect { service.call }.to change { SchoolLink.predecessor.count }.by(1)
          end
        end

        it "marks the change as handled" do
          service.call
          expect(school_change.reload).to be_handled
        end
      end
    end
  end
end
