# frozen_string_literal: true

module ApiOrderable
  extend ActiveSupport::Concern

private

  def sort_params(params, model: controller_name.classify.constantize)
    sort = []
    if params[:sort]
      sort_order = { "+" => "ASC", "-" => "DESC" }

      sorted_params = params[:sort].split(",")
      sorted_params.each do |attr|
        sort_sign = attr =~ /\A[+-]/ ? attr.slice!(0) : "+"

        if model.attribute_names.include?(attr)
          sort << "#{model.table_name}.#{attr} #{sort_order[sort_sign]}"
        end
      end
    end
    sort.join(", ")
  end
end
