class InviteSchoolsController < ApplicationController
  def show
    @find_school_form = FindSchoolForm.new
  end

  def create
    @find_school_form = FindSchoolForm.new(*find_school_form_params)
    if @find_school_form.valid?
      redirect_to supplier_dashboard_path
    else
      render :show
    end
  end

private

  def find_school_form_params
    params.require(:find_school_form).permit(%i[search_type name_url_postcode local_authority network geography])
  end
end
