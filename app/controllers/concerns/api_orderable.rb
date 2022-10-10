# frozen_string_literal: true

module ApiOrderable
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :model_klass

  private

    def orderable(model_klass: nil)
      @model_klass = model_klass
    end
  end

  def sort_params(params)
    sort = {}
    if params[:sort]
      sort_order = { "+" => :asc, "-" => :desc }

      sorted_params = params[:sort].split(",")
      sorted_params.each do |attr|
        sort_sign = attr =~ /\A[+-]/ ? attr.slice!(0) : "+"

        model = self.class.model_klass.presence || controller_name.classify.constantize
        if model.attribute_names.include?(attr)
          sort[attr] = sort_order[sort_sign]
        end
      end
    end
    sort
  end
end
