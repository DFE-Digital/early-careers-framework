# frozen_string_literal: true

module Schools
  class Year2020Controller < ApplicationController
    before_action :load_year_2020_form
    SESSION_KEY = :schools_year2020_form

    def start
      unless params[:continue]
        session.delete(SESSION_KEY)
        load_year_2020_form
      end
    end

    def select_induction_programme; end

    def choose_induction_programme
      render :select_induction_programme and return unless @year_2020_form.valid? :choose_induction_programme

      session[SESSION_KEY] = @year_2020_form.serializable_hash
      if @year_2020_form.opt_out?
        @year_2020_form.opt_out!
        redirect_to action: :no_accredited_materials
      else
        redirect_to action: :select_cip
      end
    end

    def select_cip; end

    def choose_cip
      render :select_cip and return unless @year_2020_form.valid? :choose_cip

      session[SESSION_KEY] = @year_2020_form.serializable_hash
      redirect_to action: :new_teacher
    end

    def new_teacher; end

    def create_teacher
      render :new_teacher and return unless @year_2020_form.valid? :create_teacher

      session[SESSION_KEY] = @year_2020_form.serializable_hash
      redirect_to action: :check
    end

    def check; end

    def confirm
      @year_2020_form.save!
      redirect_to action: :success
    end

    def success; end

    def no_accredited_materials; end

  private

    def load_year_2020_form
      @year_2020_form = Year2020Form.new(get_year_2020_session.merge(school_id: params[:school_id]))
      @year_2020_form.assign_attributes(year_2020_params)
    end

    def year_2020_params
      return {} unless params.key?(:schools_year2020_form)

      params.require(:schools_year2020_form).permit(:induction_programme_choice, :core_induction_programme_id, :full_name, :email)
    end

    def get_year_2020_session
      session[SESSION_KEY] || {}
    end
  end
end
