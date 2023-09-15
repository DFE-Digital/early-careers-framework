# frozen_string_literal: true

class NameMatcher
  attr_reader :name1, :name2, :check_first_name_only

  TITLES = /\A((mr|mrs|miss|ms|dr|prof|rev)\.?)/

  def initialize(name1, name2, check_first_name_only: true)
    @name1 = name1
    @name2 = name2
    @check_first_name_only = check_first_name_only
  end

  def matches?
    if check_first_name_only?
      first_name(name1).downcase == first_name(name2).downcase
    else
      strip_title(name1).downcase == strip_title(name2).downcase
    end
  end

private

  alias_method :check_first_name_only?, :check_first_name_only

  def first_name(name)
    strip_title(name).split(" ").first
  end

  def strip_title(str)
    parts = str.split(" ")
    parts.first.downcase =~ TITLES ? parts.drop(1).join(" ") : str
  end
end
