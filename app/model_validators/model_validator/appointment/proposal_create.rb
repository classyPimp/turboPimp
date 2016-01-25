class ModelValidator::Appointment::ProposalCreate

  def self.validate!(appointment)
    self.new(appointment).validate!    
  end

  def initialize(appointment)
    @a = appointment
  end

  def validate!
    validate_start_date
  end

  def validate_start_date
    unless @a.start_date.is_a?(ActiveSupport::TimeWithZone) || @a.start_date.is_a?(Date) 
      @a.custom_errors[:start_date] = "is invalid" and return
    end

    if @a.start_date < Time.now
      @a.custom_errors[:start_date] = "can't be in past"
    end
    
  end

end