# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_user!

  def policy_scope(scope)
    super([:admin, scope])
  end

  def authorize(record, query = nil)
    super([:admin, record], query)
  end
end
