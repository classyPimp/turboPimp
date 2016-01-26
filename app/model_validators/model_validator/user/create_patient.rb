class ModelValidator::User::CreatePatient

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
    unless @a.email.blank?
      unless @a.email.match(/.+@.+\..+/i)
        @a.custom_errors[:email] = 'invalid'
      end
    end
  end

  def validate_profile
    unless @a.profile
      @a.custom_errors[:base] = 'error occured: something is not right with input'
    end

    ModelValidator::Profile::CreatePatient.validate!(@a.profile)
  end

end