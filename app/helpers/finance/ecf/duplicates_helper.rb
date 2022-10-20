module Finance
  module ECF
    module DuplicatesHelper
      def tag_for(participant_profile)
        if participant_profile.master_profile?
          govuk_tag(text: "master", colour: "green")
        else
          govuk_tag(text: "duplicate", colour: "red")
        end
      end
    end
  end
end
