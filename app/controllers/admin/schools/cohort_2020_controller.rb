# frozen_string_literal: true

module Admin
  module Schools
    class Cohort2020Controller < Admin::BaseController
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def show
        @participant_profiles = policy_scope(ParticipantProfile::ECF, policy_scope_class: ParticipantProfilePolicy::Scope)
                                  .active_record
                                  .where(school_cohort_id: school_cohort.id)
                                  .includes(:user)
                                  .order("users.full_name")
      end

      def new
        @user = User.new
      end

      def create
        @user = User.find_or_initialize_by(params.require(:user).permit(:email))
        @user.full_name = params.dig(:user, :full_name)

        render :new and return unless @user.valid?

        if @user.early_career_teacher?
          if (ect_profile = @user.teacher_profile.current_ecf_profile)
            @user.errors.add(:base, I18n.t(:admin_nqt_1_email_used_ect, urn: ect_profile.school.urn))
          else
            nqt_profile = @user.teacher_profile.early_career_teacher_profile
            @user.errors.add(:base, I18n.t(:admin_nqt_1_email_used_nqt, urn: nqt_profile.school.urn))
          end
          render :new and return
        end

        EarlyCareerTeachers::Create.call(
          full_name: @user.full_name,
          email: @user.email,
          school_cohort:,
          mentor_profile_id: nil,
          year_2020: true,
        )

        set_success_message(title: "Success", heading: "NQT+1 created", content: "")
        redirect_to admin_school_cohort2020_path
      end

    private

      def school
        @school ||= School.friendly.find params[:school_id]
      end

      def school_cohort
        SchoolCohort.find_by(school:, cohort: Cohort[2020])
      end
    end
  end
end
