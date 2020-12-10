# frozen_string_literal: true

class GovspeakTestController < ApplicationController
  def show
    @content = Govspeak::Document.new("").to_html
  end

  def preview
    preview_string = params[:preview_string]
    @content = Govspeak::Document.new(preview_string).to_html
    render :show
  end
end
