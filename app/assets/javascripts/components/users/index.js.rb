module Components
  module Users
    class Index < RW

      expose
        
      def get_initial_state
        {
          users: ModelCollection.new
        }
      end

      def component_did_mount
        User.index.then do |users|
          set_state users: users
        end
      end

      def render
        t(:div, {},
          *splat_each(state.users) do |user|
            t(:div, {},
              t(:div, {style: {width: "60px", height: "60px"}}),
              t(:p, {}, email: user.email),
              t(:p, {}, name: link_to(user.profile.name, "/users/show/#{user.id}")),
              t(:button, {onClick: ->{edit_selected(user)}}, "edit"),
              t(:button, {onClick: ->{destroy_selected}}, "destroy")
            )
          end
        )
      end

      def edit_selected(user)
        
      end

      def destroy_selected(user)
        
      end

    end
  end
end