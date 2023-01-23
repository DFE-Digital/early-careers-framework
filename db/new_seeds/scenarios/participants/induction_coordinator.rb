# frozen_string_literal: true

module NewSeeds
  module Scenarios
    class InductionCoordinator
      attr_reader :induction_programme, :email, :full_name, :school_cohort, :user, :induction_coordinator_profile

      def initialize(induction_programme:, email:, full_name: nil)
        raise "Induction programme must be :fip or :cip" unless induction_programme.in?(%i[fip cip])

        @induction_programme = induction_programme
        @email = email
        @full_name = full_name
      end

      def build
        @school_cohort = FactoryBot.create(:seed_school_cohort, induction_programme, :valid)
        @user = FactoryBot.create(:user, email:, **user_args)
        @induction_coordinator_profile = FactoryBot.create(:seed_induction_coordinator_profile, user:)

        @induction_coordinator_profile.schools << @school_cohort.school
      end

    private

      def user_args
        { full_name: }.compact
      end
    end
  end
end
