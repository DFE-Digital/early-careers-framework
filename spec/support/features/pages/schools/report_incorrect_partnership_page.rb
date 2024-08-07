# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class ReportIncorrectPartnershipPage < ::Pages::BasePage
    set_url "/report-incorrect-partnership{?token}"
    set_primary_heading "Report that your school has been signed up incorrectly"

    def self.load_from_email(challenge_token)
      page_object = new
      page_object.load token: challenge_token, with_validations: false
    end

    def view_details
      click_on "View details"
    end

    def report_a_mistake
      choose "This looks like a mistake"
      click_on "Submit"

      Pages::ReportIncorrectPartnershipSuccessPage.loaded
    end

    def report_an_unrecognised_provider
      choose "I do not recognise this training provider"
      click_on "Submit"

      Pages::ReportIncorrectPartnershipSuccessPage.loaded
    end

    # Additional answers
    #   - I have already confirmed an agreement with another provider
    #   - We have not confirmed an agreement
    #   - We do not have any early career teachers this year
  end

  class ReportIncorrectPartnershipSuccessPage < ::Pages::BasePage
    set_url "/report-incorrect-partnership/success"
    set_primary_heading "Your report has been submitted"
  end

  class ReportIncorrectPartnershipAlreadyChallengedPage < ::Pages::BasePage
    set_url "/report-incorrect-partnership/already-challenged"
    set_primary_heading(/^Someone at .* has already reported this issue$/)
  end

  class ReportIncorrectPartnershipLinkExpiredPage < ::Pages::BasePage
    set_url "/report-incorrect-partnership/link-expired"
    set_primary_heading "This link has expired"
  end
end
