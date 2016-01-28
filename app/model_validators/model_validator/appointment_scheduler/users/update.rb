class ModelValidator::AppointmentScheduler::Users::Update

  def self.validate!(user)
    self.new(user).validate!    
  end

  def initialize(user)
    @a = user
  end

  def validate!
    validate_email
    validate_profile
  end

  def validate_email
    if @a.changed_attributes[:email]
      unless @a.email.match(/.+@.+\..+/i)
        @a.custom_errors[:email] = 'invalid'
      end
    end
  end

  def validate_profile
    if @a.profile.changed?
      ModelValidator::Profile::PatientUpdateByAppointmentScheduler.validate!(@a.profile)
    end 
  end

end