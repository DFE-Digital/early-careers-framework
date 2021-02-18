# frozen_string_literal: true

class LeadProvider::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  after_action :verify_authorized
  after_action :verify_policy_scoped
end
