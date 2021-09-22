# frozen_string_literal: true

module SchoolHelper
  def format(type)
    case type
    when :ect
      "ECT"
    when :mentor
      "Mentor"
    else
      type
    end
  end
end
