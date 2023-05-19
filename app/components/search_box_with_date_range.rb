# frozen_string_literal: true

class SearchBoxWithDateRange < BaseComponent
  def initialize(query:, title: "Search", hint: nil, param_name: :query, filters: [], start_date: nil, end_date: nil)
    @query = query
    @title = title
    @hint = hint
    @param_name = param_name
    @filters = filters
    @start_date = start_date
    @end_date = end_date
  end
  
private
  
  attr_reader :query, :title, :hint, :param_name, :filters, :start_date, :end_date
end
