class Doctor::UsersController < ApplicationController

  def doctors_feed
    
    perms_for User
    auth! @perms

    @doctors_feed = Profile.joins(user: [:roles]).where('roles.name = ?', 'doctor').select( :user_id, :name )

    render json: @doctors_feed.as_json(@perms.serialize_on_success)

  end

  def index_doctors_for_group_list
    
    @users = User.joins(:roles).where('roles.name = ?', 'doctor').select(:id)  

    @users.includes(:si_profile1id_name, :avatar)

    render json: @users.as_json(include: {
            avatar:  { root: true, only: [:id], methods: [:url] },
            profile: { root: true, only: [:id,  :name]}
          })

  end

  def show
    @user = User.joins(:roles).where('roles.name = ?', 'doctor').select(:id).find(params[:id])

    render json: @user.as_json(
      include:
      [
        {
          avatar:
          {
            root: true,
            only: [:id],
            methods: [:url]
          }
        },
        {
          si_profile1id_name_bio:
          {
            root: true
          }
        }
      ] 
    )

  end


end
