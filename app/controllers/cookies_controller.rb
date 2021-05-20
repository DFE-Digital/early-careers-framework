# frozen_string_literal: true

class CookiesController < ApplicationController
  before_action :set_cookie_form, only: :show

  def show
    @backlink = session[:return_to]
  end

  def update
    analytics_consent = params[:cookies_form][:analytics_consent]
    if %w[on off].include?(analytics_consent)
      cookies[:cookie_consent_1] = { value: analytics_consent, expires: 1.year.from_now }
    end

    respond_to do |format|
      format.html do
        set_cookie_form
        set_success_message(content: "You’ve set your cookie preferences.", title: "Success")
        redirect_to cookies_path
      end

      format.json do
        render json: {
          status: "ok",
          message: %(You’ve #{analytics_consent == 'on' ? 'accepted' : 'rejected'} analytics cookies.),
        }
      end
    end
  end

private

  def set_cookie_form
    @cookies_form = CookiesForm.new(analytics_consent: cookies[:cookie_consent_1])
  end
end
