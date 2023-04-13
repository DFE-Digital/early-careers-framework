# frozen_string_literal: true

class FormData::DataStore
  attr_reader :store

  def initialize(session:, form_key:)
    @session = session
    @form_key = form_key
    @store = session[form_key] ||= {}
  end

  def set(key, value)
    store[key.to_sym] = value
  end

  def get(key)
    store[key.to_sym]
  end

  def bulk_get(keys)
    store.slice(*keys.map(&:to_sym))
  end

  def get_date(key)
    v = get(key)
    return if v.nil?

    if v.respond_to? :day
      v
    elsif v.instance_of?(String)
      Date.parse(v)
    end
  end

  def destroy
    @session.delete(@form_key)
  end
end
