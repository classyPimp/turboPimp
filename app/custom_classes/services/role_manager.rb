module Services
  class RoleManager
    def self.allowed_global_roles
      ["root", "admin", "doctor", "patient"]   
    end

    def self.allowed_page_roles
      ["author"]
    end
  end
end