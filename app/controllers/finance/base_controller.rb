# frozen_string_literal: true

module Finance
  class BaseController < ApplicationController
    include Pundit::Authorization
    include FinanceHelper

    before_action :authenticate_user!
    before_action :ensure_finance
    before_action :set_paper_trail_whodunnit

    layout "finance"

  private

    def ensure_finance
      raise Pundit::NotAuthorizedError, I18n.t(:forbidden) unless current_user.finance?
    end
  end
end
