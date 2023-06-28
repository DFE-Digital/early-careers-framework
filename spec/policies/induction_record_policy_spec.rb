# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionRecordPolicy, type: :policy do
  subject { described_class.new(user, induction_record) }

  let(:user) { scenario.user }
  let(:induction_record) { build(:induction_record) }

  context "being a super user admin" do
    let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build.with_super_user }

    it { is_expected.to permit_actions(%i[edit_preferred_email update_preferred_email]) }
  end

  context "being an admin" do
    let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build }

    it {
      is_expected.to permit_actions(%i[edit_appropriate_body
                                       edit_email
                                       edit_mentor
                                       edit_name
                                       update_appropriate_body
                                       update_email
                                       update_mentor
                                       update_name])
    }

    it {
      is_expected.to forbid_actions(%i[edit_preferred_email
                                       update_preferred_email])
    }
  end

  context "being a school induction tutor" do
    let(:cohort) { Cohort.current || create(:cohort, :current) }
    let(:programme_type) { :full_induction_programme }
    let(:scenario) do
      NewSeeds::Scenarios::Schools::School.new
                                          .build
                                          .with_an_induction_tutor
                                          .with_school_cohort_and_programme(cohort:, programme_type:)
    end
    let(:induction_programme) { scenario.induction_programme }
    let(:user) { scenario.induction_tutor }

    context "current induction record" do
      let(:induction_record) { build(:induction_record, induction_programme:) }

      it {
        is_expected.to permit_actions(%i[edit_appropriate_body
                                         edit_email
                                         edit_mentor
                                         edit_name
                                         update_appropriate_body
                                         update_email
                                         update_mentor
                                         update_name])
      }
    end

    context "transferring in induction record" do
      let(:induction_record) { build(:induction_record, :school_transfer, induction_programme:, start_date: Date.tomorrow) }

      it {
        is_expected.to permit_actions(%i[edit_appropriate_body
                                         edit_email
                                         edit_mentor
                                         update_appropriate_body
                                         update_email
                                         update_mentor])
      }
    end

    context "other induction records" do
      let(:induction_record) { build(:induction_record, induction_programme:, induction_status: :changed) }

      it {
        is_expected.to forbid_actions(%i[edit_appropriate_body
                                         edit_email
                                         edit_mentor
                                         edit_name
                                         update_appropriate_body
                                         update_email
                                         update_mentor
                                         update_name])
      }
    end
  end

  context "any other user" do
    let(:scenario) { NewSeeds::Scenarios::Users::FinanceUser.new.build }

    it {
      is_expected.to forbid_actions(%i[edit_appropriate_body
                                       edit_email
                                       edit_mentor
                                       edit_name
                                       update_appropriate_body
                                       update_email
                                       update_mentor
                                       update_name])
    }
  end
end
