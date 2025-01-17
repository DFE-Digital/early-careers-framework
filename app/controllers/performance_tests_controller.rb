# frozen_string_literal: true

class PerformanceTestsController < ApplicationController
  before_action do
    Rack::MiniProfiler.authorize_request
  end

  def index; end
end
