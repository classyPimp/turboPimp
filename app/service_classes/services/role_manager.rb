module Services
  class RoleManager
    def self.allowed_global_roles
      ["root", "admin", "doctor", "patient", "blogger", "appointment_scheduler", 'from_chat', 'from_proposal']   
    end

    def self.allowed_page_roles
      ["author"]
    end

    def self.allowed_blog_roles
      ["author"]
    end
  end
end