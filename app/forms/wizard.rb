# frozen_string_literal: true

class Wizard
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  class AlreadyInitialised < StandardError; end

  class InvalidStep < StandardError; end

  # Schools::Cohorts::SetupWizard and :schools_cohorts_setup_wizard
  def self.to_key
    name.underscore.parameterize(separator: "_").to_sym
  end

  attr_reader :current_step, :current_user, :data_store, :default_step_name, :submitted_params

  delegate :to_key, to: "self.class"
  delegate :after_render, :before_render, :terminal_step?, :view_name, :valid?, to: :form
  delegate :changing_answer?, :complete?, :last_visited_step, :return_point,
           to: :data_store

  def initialize(data_store:, current_step:, current_user:, default_step_name:, submitted_params: {}, **opts)
    @current_user = current_user
    @default_step_name = default_step_name
    # @data_store = data_store_class.new(session:, form_key: to_key)
    @data_store = data_store
    @previous_step = nil
    @return_point = nil
    @submitted_params = submitted_params
    set_current_step(current_step)
    check_data_store!
    store_current_user!
    after_initialize(**opts)
    check_step_expected!
  end

  def abort?
    [nil, :abort].include?(last_visited_step)
  end

  def abort_path
    raise NotImplementedError
  end

  def after_initialize(*); end

  def change_path_for(step:)
    raise NotImplementedError
  end

  def changing_answer(boolean)
    data_store.set(:changing_answer, boolean)
  end

  def check_data_store!
    clean_data_store_at_start! || forbid_unexpected_start_of_journey!
  end

  def check_step_expected!
    raise(InvalidStep, "Previous steps not visited!") unless form.expected?
  end

  def clean_data_store_at_start!
    return false unless default_step?

    data_store.clean if submitted_params.empty?
    true
  end

  def complete!
    data_store.set(:complete, true)
  end

  def data_store_class
    raise NotImplementedError
  end

  def default_step?
    current_step == default_step_name
  end

  def forbid_unexpected_start_of_journey!
    raise(InvalidStep, "Datastore is empty at [#{current_step}]") if starting_journey_not_from_the_start?
  end

  def form
    @form ||= form_class.new(wizard: self, **load_from_data_store, **submitted_params)
  end

  def form_class
    @form_class ||= form_class_for(current_step)
  end

  # Schools::Cohorts::SetupWizard and :start => Schools::Cohorts::WizardSteps::StartStep
  def form_class_for(step)
    "#{self.class.name.deconstantize}::WizardSteps::#{step.to_s.camelcase}Step".constantize
  end

  def history_stack
    @history_stack ||= data_store.history_stack
  end

  def load_from_data_store
    data_store.bulk_get(form_class.permitted_params)
  end

  def next_journey?
    next_step == :next_journey
  end

  def next_journey_path
    raise NotImplementedError
  end

  def next_step
    @next_step ||= form.next_step
  end

  def next_step_path
    return next_journey_path if next_journey?
    return change_path_for(step: next_step) if changing_answer?

    show_path_for(step: next_step)
  end

  def previous_step_path
    return show_path_for(step: return_point) if changing_answer?
    return abort_path if abort?

    show_path_for(step: last_visited_step)
  end

  def save!
    save_progress!
    if form.complete?
      success
      complete!
    end
  end

  def save_progress!
    form.before_save
    form.attributes.each { |k, v| data_store.set(k, v) }
    form.after_save
  end

  def set_current_step(step)
    @current_step = self.class.steps.find { |s| s == step.to_sym }
    raise InvalidStep, "Could not find step: #{step}" unless current_step
  end

  def set_return_point(step)
    data_store.set(:return_point, step)
  end

  def show_path_for(step:)
    raise NotImplementedError
  end

  def starting_journey_not_from_the_start?
    history_stack.first != default_step_name
  end

  def store_current_user!
    if data_store.current_user.present? && data_store.current_user != current_user
      raise AlreadyInitialised, "current_user different"
    end

    data_store.set(:current_user, current_user)
  end

  def update_history
    previous = history_stack.last

    if changing_answer?
      # if changing the answer corrects the problem we will move straight on
      # to the next step so we do not want to keep the return point in the stack
      history_stack.pop if previous == return_point
    else
      if previous != current_step
        # on a new step
        if history_stack.second_to_last == current_step
          # we've gone back
          history_stack.pop
          previous = history_stack.second_to_last
        else
          # we've moved forward
          history_stack.push(current_step)
        end
      else
        previous = history_stack.second_to_last
      end
      data_store.set(:last_visited_step, previous)
      data_store.set(:history_stack, history_stack)
    end
  end
end
