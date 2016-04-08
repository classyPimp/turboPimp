class AppointmentsController < ApplicationController

  def index
    byebug
    @appointments =  Appointment.where("appointments.start_date >= ? AND appointments.end_date <= ?", from, to ).select(:start_date, :end_date, :doctor_id).order(:start_date)
    render json: @appointments.as_json
  end

  def new
    if current_user
      render json: @current_user.as_json(only: [:id], include: [profile: {root: true, only: [:phone_number, :id]}])
    else
      render json: {user: {unregistered: true}}
    end
  end

  def create

    @appointment = Appointment.new 

    perms_for @appointment
    auth! @perms

    @appointment_attrs = AttributesPermitter::Appointment::Proposal::Create.new(params).get_permitted

    if @perms.arbitrary[:registered_user] == true
  
      cmpsr = ComposerFor::Appointment::Proposal::CreateByRegisteredUser.new(@appointment, @appointment_attrs, @current_user.id)   

    elsif @perms.arbitrary[:registered_user] == false

      user_permitted_attributes = AttributesPermitter::User::Unregistered::Create.new(params).get_permitted
      cmpsr = ComposerFor::Appointment::Proposal::CreateByUnregisteredUser.new(@appointment, @appointment_attrs,
                                                                               user_permitted_attributes)
    
    else
    
      raise "#{self} expects: @perms (#{@perms}) to specify in it's arbitrary data if [:registered_user] is true || false"
   
    end

    cmpsr.when(:ok) do |appointment|
      render json: appointment.as_json(@perms.serialize_on_success)
    end

    cmpsr.when(:fail) do |appointment|
      render json: appointment.as_json(@perms.serialize_on_error)
    end

    cmpsr.when(:fail_unregistered_user_validation) do |user|
      render json: user.as_json(only: [], methods: [:errors], include: [profile: {root: true, methods: [:errors], only: []}])
    end

    cmpsr.run

  end

end
