# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    render template: "pages/#{params[:page].tr('-', '_')}"
  end

  def induction_tutor_materials
    provider_name = params[:provider]
    render template: "pages/induction_tutor_materials/#{folder_name(provider_name)}/#{params[:year].tr('-', '_')}"
  end

private

  def folder_name(provider_name)
    case provider_name
    when "ambition-institute"
      "ambition"
    when "educational-development-trust"
      "educational_development_trust"
    when "teach-first"
      "teach_first"
    when "ucl-institute-of-education"
      "ucl"
    end
  end
end
