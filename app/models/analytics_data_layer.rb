# frozen_string_literal: true

##
# The AnalyticsDataLayer enables pushing key value pairs to the Google Analytics `dataLayer`
# The app/helpers/application_helper.rb sets up an instance of this class named "data_layer"
# The js variable dataLayer is initialised in app/views/layouts/_application.html.erb and by default will
# be populated with `current_user` info and also the URN of any school in the view assigns hash.
# To add any additional view specific key/value pairs from any view:
#
#   <% data_layer.add(mykey: "my value", my_hash: { a: 1, b: 2}) %>
#
# The collected data is split into an array of key value pairs when rendered in the layout using .to_json
#
# e.g.
# <script>
#   dataLayer = [{"mykey":"my value"},{"my_hash":{"a":1,"b":2}}];
# </script>
#

class AnalyticsDataLayer
  attr_accessor :analytics_data

  def initialize
    @analytics_data = {}
  end

  def add(data = {})
    @analytics_data.merge!(data)
  end

  def add_user_info(user)
    @analytics_data[:userType] = user.user_type if user
    @analytics_data[:providerId] = user.lead_provider.id if user&.lead_provider?
  end

  def add_school_info(school)
    @analytics_data[:schoolId] = school.urn if school
  end

  def as_json(_opts = nil)
    analytics_data.map { |k, v| { k => v } }
  end
end
