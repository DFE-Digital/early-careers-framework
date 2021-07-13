# frozen_string_literal: true

class SearchBox < BaseComponent
  def initialize(query:, title: "Search", hint: nil, param_name: :query)
    @query = query
    @title = title
    @hint = hint
    @param_name = param_name
  end

private

  attr_reader :query, :title, :hint, :param_name
end
