# frozen_string_literal: true

class Admin::Performance::EmailSchedulesController < Admin::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :set_email_schedule, only: %i[show edit update destroy]

  def index
    @upcoming_emails = EmailSchedule.queued.order(:scheduled_at)
    @recently_sent = EmailSchedule.where.not(status: :queued).order(scheduled_at: :desc).limit(20)
  end

  def show; end

  def new
    @email_schedule = EmailSchedule.new
  end

  def edit; end

  def create
    @email_schedule = EmailSchedule.new(email_schedule_params)

    if @email_schedule.save
      set_success_message content: "Email has been scheduled"
      redirect_to admin_performance_email_schedules_url
    else
      render :new
    end
  end

  def update
    if @email_schedule.update(email_schedule_params)
      set_success_message content: "Email scheduled has been updated"
      redirect_to admin_performance_email_schedules_url
    else
      render :edit
    end
  end

  def destroy
    @email_schedule.destroy!
    set_success_message(content: "Email schedule deleted", title: "Success")
    redirect_to admin_performance_email_schedules_url
  end

private

  def set_email_schedule
    @email_schedule = EmailSchedule.find(params[:id])
  end

  def email_schedule_params
    params.fetch(:email_schedule, {}).permit(:mailer_name, :scheduled_at)
  end
end
