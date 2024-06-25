# frozen_string_literal: true

module Steps
  module CookiesPolicySteps
    include RSpec::Matchers

    def given_i_am_on_the_start_page
      @start_page = Pages::StartPage.load
    end

    def when_i_view_cookie_policy_from_the_start_page
      @start_page.view_cookie_policy
    end

    def when_i_go_back_from_the_cookie_policy_page
      @cookies_policy_page.go_back
    end

    def when_i_give_cookie_consent_on_the_cookie_policy_page
      @cookies_policy_page.give_cookie_consent
    end
    alias_method :and_i_give_cookie_consent_on_the_cookie_policy_page, :when_i_give_cookie_consent_on_the_cookie_policy_page

    def when_i_revoke_cookie_consent_on_the_cookie_policy_page
      @cookies_policy_page.revoke_cookie_consent
    end
    alias_method :and_i_revoke_cookie_consent_on_the_cookie_policy_page, :when_i_revoke_cookie_consent_on_the_cookie_policy_page

    def when_i_reject_cookies_on_the_start_page
      @start_page.reject_cookies
    end
    alias_method :and_i_reject_cookies_on_the_start_page, :when_i_reject_cookies_on_the_start_page

    def when_i_hide_success_message_on_the_start_page
      @start_page.hide_success_message
    end

    def when_i_accept_cookies_on_the_start_page
      @start_page.accept_cookies
    end
    alias_method :and_i_accept_cookies_on_the_start_page, :when_i_accept_cookies_on_the_start_page

    def and_i_confirm_cookie_preferences_rejected_on_the_start_page
      @start_page.confirm_cookie_preferences_rejected
    end

    def and_i_confirm_cookie_preferences_accepted_on_the_start_page
      @start_page.confirm_cookie_preferences_accepted
    end

    def then_i_am_on_the_cookie_policy_page
      @cookies_policy_page = Pages::CookiePolicyPage.load
      @cookies_policy_page.loaded
    end
    alias_method :given_i_am_on_the_cookie_policy_page, :then_i_am_on_the_cookie_policy_page
    alias_method :and_i_am_on_the_cookie_policy_page, :then_i_am_on_the_cookie_policy_page
    alias_method :when_i_am_on_the_cookie_policy_page, :then_i_am_on_the_cookie_policy_page

    def then_i_am_on_the_start_page
      @start_page.loaded
    end

    def then_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
      @cookies_policy_page.confirm_cookie_consent_is_given
    end
    alias_method :and_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page, :then_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page

    def then_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page
      @cookies_policy_page.confirm_cookie_consent_is_not_given
    end
    alias_method :and_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page, :then_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page

    def then_i_confirm_cookie_banner_displayed_on_the_start_page
      @start_page.confirm_cookie_banner_displayed
    end

    def then_i_confirm_cookie_banner_not_displayed_on_the_start_page
      @start_page.confirm_cookie_banner_not_displayed
    end
  end
end
