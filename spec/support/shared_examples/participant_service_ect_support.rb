# frozen_string_literal: true

RSpec.shared_examples "a participant service for ect" do
  context "when valid user is an early_career_teacher" do
    it "fails when course is for a mentor" do
      params = given_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.new(params: params).call }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for an npq-course" do
      params = given_params.merge({ course_identifier: "npq-leading-teacher" })
      expect { described_class.new(params: params).call }.to raise_error(ActionController::ParameterMissing)
    end

    context "when user is for 2020 cohort" do
      let!(:cohort_2020) { create(:cohort, start_year: 2020) }
      let!(:school_cohort_2020) { create(:school_cohort, cohort: cohort_2020, school: user_profile.school) }

      before do
        induction_programme.update!(school_cohort: school_cohort_2020)
      end

      it "raises a ParameterMissing error" do
        expect { described_class.new(params: given_params).call }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
