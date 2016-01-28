class ModelValidator::Profile::PatientUpdateByAppointmentScheduler

  def self.validate!(profile)
    self.new(profile).validate! 
  end

  def initialize(profile)
    @a = profile
  end

  def validate!
    validate_name
    validate_phone_number
  end

  def validate_name
    if @a.changed_attributes[:name] 
      if @a.name.blank?
        @a.custom_errors[:name] = 'should be provided' and return
      end
    end
  end

  def validate_phone_number
    if @a.changed_attributes[:phone_number]
      if @a.phone_number.blank?
        @a.custom_errors[:phone_number] = 'should be provided' and return
      end
    end
  end

end