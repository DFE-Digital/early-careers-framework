# frozen_string_literal: true

module Admin::TestData
  class UnclaimedSchoolsController < Admin::TestData::BaseController
    before_action :get_school, only: :generate_link

    def index
      @pagy, @schools = pagy(find_schools, page: params[:page], items: 10)
    end

    def generate_link
      nomination_email = NominationEmail.create_nomination_email(
        sent_to: current_user.email,
        sent_at: Time.zone.now,
        school: @school,
      )

      nomination_url = nomination_email.plain_nomination_url
      set_success_message(heading: "Nomination link for #{@school.name}:", content: helpers.govuk_link_to(nomination_url))
      redirect_to admin_test_data_unclaimed_schools_path
    end

  private

    def find_schools
      policy_scope(School)
        .where.missing(:induction_coordinator_profiles_schools)
        .includes(:nomination_emails)
        .order(:urn)
    end

    def get_school
      @school = policy_scope(School).friendly.find(params[:id])
    end
  end
end
