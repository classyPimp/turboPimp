class OfferedServiceAvatar < Model

  attributes :id, :avatar, :url, :offered_service_id

  def validate_file
    self.has_file = true
  end

end