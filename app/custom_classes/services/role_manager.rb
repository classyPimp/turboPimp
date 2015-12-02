module Services
  class RoleManager
    def self.allowed_roles
      ["root", "admin", "doctor", "patient"]
    end
  end
end