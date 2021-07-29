# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ChangeInductionService do
  let(:cohort) { create(:cohort) }
  let(:current_school_cohort) { school.school_cohorts.find_by(cohort: cohort) }
  subject(:service) { Admin::ChangeInductionService.new(school: school, cohort: cohort) }

  describe "#change_induction_provision" do
    context "when the school has not selected an induction" do
      let(:school) { create(:school) }
      it "should be able to choose CIP" do
        expect_to_set_to :core_induction_programme
      end

      it "should be able to choose FIP" do
        expect_to_set_to :full_induction_programme
      end

      it "should be able to choose NoECTs" do
        expect_to_set_to :no_early_career_teachers
      end

      it "should be able to choose DIY" do
        expect_to_set_to :design_our_own
      end
    end

    context "when the school has selected CIP" do
      let!(:school) { create(:school_cohort, induction_programme_choice: "core_induction_programme", cohort: cohort).school }

      it "should be able to choose FIP" do
        expect_to_change_to :full_induction_programme
      end

      it "should be able to choose NoECTs" do
        expect_to_change_to :no_early_career_teachers
      end

      it "should be able to choose DIY" do
        expect_to_change_to :design_our_own
      end

      context "when the school has chosen CIP materials" do
        let!(:school) do
          create(:school_cohort,
                 induction_programme_choice: "core_induction_programme",
                 core_induction_programme: create(:core_induction_programme),
                 cohort: cohort).school
        end

        it "should be able to choose FIP" do
          expect_to_change_to :full_induction_programme
          expect(current_school_cohort.core_induction_programme).to be_nil
        end

        it "should be able to choose NoECTs" do
          expect_to_change_to :no_early_career_teachers
          expect(current_school_cohort.core_induction_programme).to be_nil
        end

        it "should be able to choose DIY" do
          expect_to_change_to :design_our_own
          expect(current_school_cohort.core_induction_programme).to be_nil
        end
      end
    end

    context "when the school has selected FIP" do
      let!(:school) { create(:school_cohort, induction_programme_choice: "full_induction_programme", cohort: cohort).school }
      context "when it is not in a partnership" do
        it "should be able to choose CIP" do
          expect_to_change_to :full_induction_programme
        end

        it "should be able to choose NoECTs" do
          expect_to_change_to :no_early_career_teachers
        end

        it "should be able to choose DIY" do
          expect_to_change_to :design_our_own
        end
      end

      context "when a school is in a partnership" do
        let!(:partnership) { create(:partnership, cohort: cohort, school: school) }
        it "should not be able to choose CIP" do
          expect { service.change_induction_provision(:core_induction_programme) }.to raise_error(ArgumentError)
                                                                                        .and not_change { current_school_cohort }
        end

        it "should not be able to choose NoECTs" do
          expect { service.change_induction_provision(:no_early_career_teachers) }.to raise_error(ArgumentError)
                                                                                        .and not_change { current_school_cohort }
        end

        it "should not be able to choose DIY" do
          expect { service.change_induction_provision(:design_our_own) }.to raise_error(ArgumentError)
                                                                              .and not_change { current_school_cohort }
        end
      end
    end

    context "when the school has selected NoECTs" do
      let!(:school) { create(:school_cohort, induction_programme_choice: "no_early_career_teachers", cohort: cohort).school }

      it "should be able to choose CIP" do
        expect_to_change_to :core_induction_programme
      end

      it "should be able to choose FIP" do
        expect_to_change_to :full_induction_programme
      end

      it "should be able to choose DIY" do
        expect_to_change_to :design_our_own
      end
    end

    context "when the school has selected DIY" do
      let!(:school) { create(:school_cohort, induction_programme_choice: "design_our_own", cohort: cohort).school }

      it "should be able to choose FIP" do
        expect_to_change_to :full_induction_programme
      end

      it "should be able to choose CIP" do
        expect_to_change_to :core_induction_programme
      end

      it "should be able to choose NoECTs" do
        expect_to_change_to :no_early_career_teachers
      end
    end

    context "when the school has participants" do
      let!(:participant_profiles) { create_list(:participant_profile, 5, :ecf, school_cohort: school.school_cohorts.first) }

      context "when the school is doing CIP" do
        let(:school) { create(:school_cohort, induction_programme_choice: "core_induction_programme", cohort: cohort).school }
        it "withdraws all participants when changing to NoECTs" do
          service.change_induction_provision(:no_early_career_teachers)
          expect(participant_profiles.all?(&:withdrawn?))
        end

        it "withdraws all participants when changing to DIY" do
          service.change_induction_provision(:design_our_own)
          expect(participant_profiles.all?(&:withdrawn?))
        end

        it "does not change participants when changing to FIP" do
          service.change_induction_provision(:full_induction_programme)
          expect(participant_profiles.all?(&:active?))
        end
      end

      context "when the school is doing FIP" do
        let(:school) { create(:school_cohort, induction_programme_choice: "full_induction_programme", cohort: cohort).school }
        it "withdraws all participants when changing to NoECTs" do
          service.change_induction_provision(:no_early_career_teachers)
          expect(participant_profiles.all?(&:withdrawn?))
        end

        it "withdraws all participants when changing to DIY" do
          service.change_induction_provision(:design_our_own)
          expect(participant_profiles.all?(&:withdrawn?))
        end

        it "does not change participants when changing to CIP" do
          service.change_induction_provision(:core_induction_programme)
          expect(participant_profiles.all?(&:active?))
        end
      end
    end
  end

  describe "#change_cip_materials" do
    context "when the school has selected CIP" do
      context "when the school has chosen materials" do
        let(:school) { create(:school_cohort, induction_programme_choice: "core_induction_programme", core_induction_programme: create(:core_induction_programme), cohort: cohort).school }

        it "changes the choice of induction materials" do
          new_cip = create(:core_induction_programme)
          service.change_cip_materials(new_cip)
          expect(current_school_cohort.core_induction_programme).to eql new_cip
        end
      end

      context "when the school has not chosen materials" do
        let(:school) { create(:school_cohort, induction_programme_choice: "core_induction_programme", cohort: cohort).school }

        it "changes the choice of materials" do
          new_cip = create(:core_induction_programme)
          service.change_cip_materials(new_cip)
          expect(current_school_cohort.core_induction_programme).to eql new_cip
        end
      end
    end

    context "when the school has not selected CIP" do
      it "does not change materials" do
        %i[full_induction_programme no_early_career_teachers design_our_own].each do |induction_programme_choice|
          school_cohort = create(:school_cohort, induction_programme_choice: induction_programme_choice, cohort: cohort)
          school = school_cohort.school

          expect {
            described_class.new(school: school, cohort: cohort).change_cip_materials(create(:core_induction_programme))
          }.to raise_error ArgumentError
          expect(school_cohort.core_induction_programme).to be_nil
        end
      end
    end
  end

private

  def expect_to_set_to(new_value)
    expect { service.change_induction_provision(new_value) }.to change { SchoolCohort.count }.by 1
    expect(current_school_cohort.induction_programme_choice).to eql new_value.to_s
  end

  def expect_to_change_to(new_value)
    expect { service.change_induction_provision(new_value) }.not_to change { SchoolCohort.count }
    expect(current_school_cohort.induction_programme_choice).to eql new_value.to_s
  end
end
