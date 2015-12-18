module Components
  module Admin
    module Users
      class Edit < RW
        expose

        def render
          t(:div, {}, 
            t(Components::Users::Edit, {as_admin: true, params: props.params})
          )
        end

      end
    end
  end
end