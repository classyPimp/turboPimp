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
    
    @perms = perms_for User  

    auth! @perms.appointment_scheduler_index

    page = params[:page] || 1
    per_page = params[:per_page] || 25
    search_query = params[:search_query]
    registered_only = params[:registered_only]
    unregistered_only = params[:unregistered_only]

    if !search_query.blank?

      @users = User.user_search(search_query).includes(:avatar, :profile, :si_profile1name_phone_number)

    else

      @users = User.all.includes(:avatar, :profile, :si_profile1name_phone_number)
    
    end


    @users = @users.joins(:roles).where('roles.name = ?', 'patient')


    unless registered_only.blank?

      @users = @users.where(registered: true)

    end

    unless unregistered_only.blank?

      @users = @users.where(registered: false)

    end

    @users = @users.select('users.id, users.email, users.registered')

    @users = @users.paginate(per_page: per_page, page: page)

    @users = @users.as_json(@perms.serialize_on_success) << self.extract_pagination_hash(@users)

    render json: @users

  end

  def edit

    @user = User.find(params[:id])
    perms_for @user
    auth! @perms.appointment_scheduler_edit
    
    render json: @user.as_json(@perms.serialize_on_success)
  
  end

  def update
    
    @user = User.find(params[:id])
    perms_for @user
    auth! @perms.appointment_scheduler_update

    user_permitted_attributes = AttributesPermitter::AppointmentScheduler::Users::Update.new(params).get_permitted

    cmpsr = ComposerFor::AppointmentScheduler::Users::Update.new(@user, user_permitted_attributes)

    cmpsr.when(:ok) do |user|
      render json: user.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |user|
      render json: user.as_json(@perms.serialize_on_error)
    end

    cmpsr.run

  end

  def destroy
    
    @user = User.find(params[:id])

    perms_for @user

    auth! @perms.appointment_scheduler_destroy

    cmpsr = ComposerFor::User::RegularDestroy.new(@user)

    cmpsr.when(:ok) do |user|
      render json: user.as_json(only: [:id])
    end

    cmpsr.when(:fail) do |user|
      render json: user.as_json(only: [:id], methods: [:errors])
    end

    cmpsr.run

  end

  def transform_user_to_registered
    @user = User.find(params[:id])
    perms_for @user
    auth! @perms.appointment_scheduler_transform_user_to_registered
    @user.registered = true
    @role_to_destroy = @user.roles.where(name: 'from_proposal').first

    @role_to_destroy.destroy if @role_to_destroy
    @user.save

    render json: @user.as_json(only: [:id, :registered])
  end

end
