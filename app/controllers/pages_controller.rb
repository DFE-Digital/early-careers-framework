# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    render template: "pages/#{params[:page].tr('-', '_')}"
  end

  def induction_tutor_materials
    render template: "pages/induction_tutor_materials/#{params[:provider].tr('-', '_').downcase}/#{params[:year].tr('-', '_')}"
  end
end
