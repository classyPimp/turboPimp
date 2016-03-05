class SelectOption < Model

  attributes :value

  def show_value
    if self.attributes[:show_value]
      self.attributes[:show_value]
    else
      self.value
    end
  end

  def show_value=(val)
    self.attributes[:show_value] = val
  end

end