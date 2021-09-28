# frozen_string_literal: true

module SchoolHelper
  def format(type)
    case type
    when :ect
      "ECT"
    when :mentor
      "mentor"
    else
      type
    end
  end
end
