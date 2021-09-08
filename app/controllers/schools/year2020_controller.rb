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

    def select_cip; end

    def choose_cip
      render :select_cip and return unless @year_2020_form.valid? :choose_cip

      store_year_2020_session
      if @year_2020_form.get_participants.count.positive?
        redirect_to action: :check
      else
        redirect_to action: :new_teacher
      end
    end

    def new_teacher; end

    def create_teacher
      render :new_teacher and return unless @year_2020_form.valid? :create_teacher

      @year_2020_form.store_new_participant
      store_year_2020_session
      redirect_to action: :check
    end

    def remove_teacher
      participant = @year_2020_form.get_participant(participant_index)
      redirect_to action: :check unless participant

      @year_2020_form.email = participant[:email]
      @year_2020_form.full_name = participant[:full_name]
    end

    def delete_teacher
      @year_2020_form.remove_participant(participant_index)
      store_year_2020_session
      redirect_to action: :check
    end

    def edit_teacher
      participant = @year_2020_form.get_participant(participant_index)
      redirect_to action: :check unless participant

      @year_2020_form.email = participant[:email]
      @year_2020_form.full_name = participant[:full_name]
    end

    def update_teacher
      render :edit_teacher and return unless @year_2020_form.valid? :update_teacher

      @year_2020_form.update_participant(participant_index)
      store_year_2020_session
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

    def store_year_2020_session
      session[SESSION_KEY] = @year_2020_form.serializable_hash
    end

    def participant_index
      params[:index].to_i
    end
  end
end
