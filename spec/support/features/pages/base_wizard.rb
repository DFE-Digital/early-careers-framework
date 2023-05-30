# frozen_string_literal: true

module Pages
  class BaseWizard
    def self.load(*args)
      wizard = new
      wizard.load(*args)
      wizard
    end

    def self.loaded(*args)
      wizard = new
      wizard.loaded(*args)
      wizard
    end

    class << self
      attr_reader :start_page

      # Sets and returns the specific start_page that will be used for a wizard object
      #
      # @return [String]
      def set_start_page(start_page)
        @start_page = start_page
      end
    end

    delegate :load, to: :start_page
    delegate :loaded, to: :start_page

    def begin
      start_page.loaded
    end

  private

    def start_page
      self.class.start_page
    end
  end
end
