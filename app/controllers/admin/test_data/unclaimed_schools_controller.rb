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

    def nomination_email_or_generate_link(school)
      nomination_email = school.nomination_emails.first

      if nomination_email.nil? || nomination_email.expired?
        helpers.govuk_link_to generate_link_admin_test_data_unclaimed_school_path(school) do
          %(Generate link <span class="govuk-visually-hidden">for #{school.name}</span>).html_safe
        end
      else
        helpers.govuk_link_to nomination_email.plain_nomination_url, nomination_email.plain_nomination_url
      end
    end

    helper_method :nomination_email_or_generate_link

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
