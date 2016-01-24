class ModelValidator::Appointment::ScheduleFromProposal

  def self.validate!(appointment)
    self.new(appointment).validate!    
  end

  def initialize(appointment)
    @a = appointment
  end

  def validate!
    validate_doctor_id
    validate_patient_id
    validate_start_date
    validate_end_date
    validate_start_and_end_difference
  end

  def validate_doctor_id

    id = @a.doctor_id

    if id.blank?
      @a.add_error(:doctor_id, 'doctor not chosen') and return
    end

    doctor = User.select(:id).find(id)
    has_role = doctor.has_role?(:doctor) if doctor

    unless has_role && doctor
      @a.errors.add(:base, 'error occured')
    end

  end

  def validate_patient_id

    id = @a.patient_id

    if id.blank?
      @a.errors.add(:patient_id, 'patient not chosen') and return
    end

    exists = User.exists?(id)

    unless exists
      @a.errors.add(:patient_id, "such patient doesn't exists")
    end

  end

  def validate_start_date
    
    unless @a.start_date.is_a?(ActiveSupport::TimeWithZone) || start_date.is_a?(Date) 
      @a.errors.add(:start_date, "is invalid")
    end

  end

  def validate_end_date
    
    unless @a.start_date.is_a?(ActiveSupport::TimeWithZone) || start_date.is_a?(Date) 
      @a.errors.add(:start_date, "is invalid")
    end

  end

  def validate_start_and_end_difference
    unless @a.end_date > @a.start_date
      @a.errors.add(:start_date, "start_date can't be grater than end date")
    end
  end

end