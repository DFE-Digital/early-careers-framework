# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    template = template_resolver.resolve(params[:page])

    raise_not_found! unless template

    render template:
  end

  def induction_tutor_materials
    page = "induction_tutor_materials/#{params[:provider]}/#{params[:year]}"
    template = template_resolver.resolve(page)

    raise_not_found! unless template

    render template:
  end

private

  def raise_not_found!
    raise ActionController::RoutingError, "Not Found"
  end

  def template_resolver
    @template_resolver ||= Pages::TemplateResolver.new(lookup_context)
  end
end
