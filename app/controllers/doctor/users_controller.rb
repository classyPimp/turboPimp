class Doctor::UsersController < ApplicationController

  def doctors_feed
    
    perms_for User
    auth! @perms

    @doctors_feed = Profile.joins(user: [:roles]).where('roles.name = ?', 'doctor').select( :user_id, :name )

    render json: @doctors_feed.as_json(@perms.serialize_on_success)

  end

end
