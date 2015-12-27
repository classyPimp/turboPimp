class PatientsController < ApplicationController

  def patients_feed
    perms_for :Patient
    auth! @perms
    feed = Profile.patients_for_feed
    render json: feed.as_json
  end

end
