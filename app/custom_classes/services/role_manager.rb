module Services
  class RoleManager
    def self.allowed_global_roles
      ["root", "admin", "doctor", "patient", "blogger"]   
    end

    def self.allowed_page_roles
      ["author"]
    end

    def self.allowed_blog_roles
      ["author"]
    end
  end
end