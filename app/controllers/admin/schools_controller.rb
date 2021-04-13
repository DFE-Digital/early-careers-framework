# frozen_string_literal: true

module Admin
  class SchoolsController < Admin::BaseController
    skip_after_action :verify_authorized, only: :index

    def index
      @schools = policy_scope(School).order(:name).page(params[:page]).per(20)
    end
  end
end
