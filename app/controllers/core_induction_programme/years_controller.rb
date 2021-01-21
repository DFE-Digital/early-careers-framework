# frozen_string_literal: true

class CoreInductionProgramme::YearsController < ApplicationController
  def show
    @course_years = CourseYear.where(lead_provider: params[:id])
    @gov_speak_content = Govspeak::Document.new(@course_years[1].content, options: { allow_extra_quotes: true }).to_html
  end
end
