# frozen_string_literal: true

require "govspeak"

class GovspeakTestController < ApplicationController
  def show
    @content = Govspeak::Document.new("").to_html
    @preview_string = ""
  end

  def preview
    @preview_string = params[:preview_string]
    @content = Govspeak::Document.new(@preview_string, options: { allow_extra_quotes: true }).to_html
    render :show
  end
end
