# frozen_string_literal: true

module ApiOrderable
  extend ActiveSupport::Concern

  SORT_ORDER = { "+" => "ASC", "-" => "DESC" }.freeze

private

  def sort_params(model: controller_name.classify.constantize)
    return unless sort_param

    sort_params = sort_param.split(",")
    sort_params.map { |sp| convert_sort_param(sp, model) }.compact.join(", ")
  end

  def convert_sort_param(sort_param, model)
    extracted_sort_sign = sort_param =~ /\A[+-]/ ? sort_param.slice!(0) : "+"
    sort_order = SORT_ORDER[extracted_sort_sign]

    return unless sort_param.in?(model.attribute_names)

    "#{model.table_name}.#{sort_param} #{sort_order}"
  end

  def sort_param
    params[:sort]
  end
end
