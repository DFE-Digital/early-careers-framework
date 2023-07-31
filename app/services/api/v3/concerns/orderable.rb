# frozen_string_literal: true

module Api
  module V3
    module Concerns
      module Orderable
        extend ActiveSupport::Concern

        SORT_ORDER = { "+" => "ASC", "-" => "DESC" }.freeze

        def sort_order(model:, default: nil)
          return default unless sort_param

          sort_params = sort_param.split(",")
          sort_params.map { |sp| convert_sort_param(sp, model) }.compact.join(", ")
        end

      private

        def sort_param
          params[:sort].presence
        end

        def convert_sort_param(sort_param, model)
          extracted_sort_sign = sort_param =~ /\A[+-]/ ? sort_param.slice!(0) : "+"
          sort_order = SORT_ORDER[extracted_sort_sign]

          return unless sort_param.in?(model.attribute_names)

          "#{model.table_name}.#{sort_param} #{sort_order}"
        end
      end
    end
  end
end
