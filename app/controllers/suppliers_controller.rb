class SuppliersController < ApplicationController
  def dashboard
    render template: "pages/supplier_dashboard"
  end
end
