# frozen_string_literal: true

require "govspeak"

class GovspeakTestController < ApplicationController
  include GovspeakHelper
  def show
    @content = content_to_html("")
    @preview_string = ""
  end

  def preview
    @preview_string = params[:preview_string]
    @content = content_to_html(@preview_string)
    render :show
  end
end
