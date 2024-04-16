# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::LatestManageableCohort do
  describe "#call" do
    let(:school) { create(:seed_school) }

    subject(:service_call) { described_class.call(school:) }

    context "when no pilot is being run" do
      context "outside the next registration period" do
        it "returns the current cohort" do
          inside_auto_assignment_window do
            expect(service_call).to eq Cohort.current
          end
        end
      end

      context "during the next registration period" do
        it "returns the active registration cohort" do
          inside_registration_window do
            expect(service_call).to eq Cohort.active_registration_cohort
          end
        end
      end
    end

    context "when the pilot feature flag is set", with_feature_flags: { registration_pilot: "active" } do
      context "outside the next registration period" do
        it "returns the current cohort" do
          inside_auto_assignment_window do
            expect(service_call).to eq Cohort.current
          end
        end
      end

      context "during the next registration period" do
        it "returns the current cohort" do
          inside_registration_window do
            expect(service_call).to eq Cohort.current
          end
        end
      end

      context "when the school is included in the pilot", with_feature_flags: { registration_pilot_school: "active" } do
        context "outside the next registration period" do
          it "returns the current cohort" do
            inside_auto_assignment_window do
              expect(service_call).to eq Cohort.current
            end
          end
        end

        context "during the next registration period" do
          it "returns the active registration cohort" do
            inside_registration_window do
              expect(service_call).to eq Cohort.active_registration_cohort
            end
          end
        end
      end
    end
  end
end
