class String
  def to_snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def to_camel_case
    self.split('_').collect(&:capitalize).join
  end

  def constantize
    self.split('::').inject(Object) {|o,c| o.const_get c}
  end
end
