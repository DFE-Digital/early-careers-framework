# frozen_string_literal: true

module ApiPagination
  extend ActiveSupport::Concern
  include Pagy::Backend

private

  def paginate(scope)
    _pagy, paginated_records = pagy_countless(scope, limit: per_page, page:)

    paginated_records
  end

  def per_page
    params[:page] ||= {}

    [(params.dig(:page, :per_page) || default_per_page).to_i, max_per_page].min
  end

  def default_per_page
    100
  end

  def max_per_page
    3000
  end

  def page
    params[:page] ||= {}
    (params.dig(:page, :page) || 1).to_i
  end
end
