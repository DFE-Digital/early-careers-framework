# frozen_string_literal: true

class ProgressLabelComponent < ViewComponent::Base
  def initialize(progress:)
    @progress_text = progress&.gsub("_", " ")
    @class = get_class_for_progress(progress)
  end

private

  def get_class_for_progress(progress)
    case progress
    when "not_started"
      "govuk-tag--grey"
    when "in_progress"
      "govuk-tag--blue"
    else
      ""
    end
  end
end
