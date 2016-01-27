class AppointmentScheduler::UsersController < ApplicationController

  def create
    
    perms_for User
    auth! @perms.appointment_scheduler_create

    permitted_attributes = AttributesPermitter::User::AppointmentScheduler::CreatePatient.new(params).get_permitted

    cmpsr = ComposerFor::AppointmentScheduler::Users::CreatePatient.new(permitted_attributes)

    cmpsr.when(:ok) do |user|
      render json: user.as_json(@perms.serialize_on_success)
    end    

    cmpsr.when(:fail) do |user|
      render json: user.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

  def index
    
    perms_for User
    auth! @perms.appointment_scheduler_index

    per_page = params[:per_page] || 25
    @users = User.includes(:si_profile1name_phone_number).all.paginate(page: params[:page], per_page: per_page)

    @pagination_hash = extract_pagination_hash(@users)  

    render json: @users.as_json(@perms.serialize_on_success) << @pagination_hash

  end

  def edit

    @user = User.find(params[:id])
    perms_for @user
    auth! @perms.appointment_scheduler_edit
    
    render json: @user.as_json(@perms.serialize_on_success)
  
  end

  def udpate
    
    @user = User.find(params[:id])
    perms_for @user
    auth! @perms.appointment_scheduler_update

    user_permitted_attributes = AttributesPermitter::AppointmentScheduler::User::Update.new(params).get_permitted

    cmpsr = ComposerFor::AppointmentScheduler::Users::Update.new(@user, )

    cmpsr.when(:ok) do |user|
      render json: user.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |user|
      render json: user.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

end
