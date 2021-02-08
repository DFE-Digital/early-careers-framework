class SchoolRegistration::EnterUrnController < ApplicationController
  def index
    @school = School.new
  end
end
