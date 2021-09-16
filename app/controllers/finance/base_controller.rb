# frozen_string_literal: true

module Finance
  class BaseController < ApplicationController
    include Pundit

    before_action :authenticate_user!
    before_action :ensure_finance

  private

    def ensure_finance
      raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.finance?
    end
  end
end
