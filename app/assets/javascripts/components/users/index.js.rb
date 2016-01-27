module Components
  module Users
    class Index < RW

      expose

      include Plugins::DependsOnCurrentUser
      set_roles_to_fetch :admin

      include Plugins::Paginatable

      def get_initial_state
        {
          users: ModelCollection.new
        }
      end

      def component_did_mount
        @as_admin = props.as_admin ? {namespace: "admin"} : {}
        User.index({extra_params: {per_page: 25}}.merge(@as_admin)).then do |users|
          extract_pagination(users)
          set_state users: users
        end
      end

      def render
        t(:div, {},
          *splat_each(state.users) do |user|
            t(:div, {},
              if user.avatar 
                t(:image, {src: user.avatar.url, style: {width: "60px", height: "60px"}.to_n })
              end,
              t(:p, {},"email: #{user.email}"),
              t(:p, {}, (link_to("name: #{user.profile.name}", "/users/show/#{user.id}" ) if user.profile) ),
                if state.current_user.has_role? :admin
                  t(:div, {},  
                    unless user.roles.empty?
                      t(:p, {}, "rights:", 
                        *splat_each(user.roles) do |role|
                          t(:span, {className: "label label-default"}, role.name)
                        end
                      )
                    end,
                    t(:br, {}),
                    t(:button, {onClick: ->{edit_selected(user)} }, "edit user"),
                    t(:button, {onClick: ->{destroy_selected(user)}}, "delete user")
                  )
                end,
              t(:hr, {style: {color: "grey", height: "1px", backgroundColor: "black"}.to_n }),      
            )
          end,
          unless state.users.data.empty?
            will_paginate
          end
        )
      end

      def edit_selected(user)
        url = @as_admin ? "/admin/users/#{user.id}/edit" : "/users/edit/#{user.id}"
        Components::App::Router.history.pushState({}, url)

      end

      def destroy_selected(_user)
        _user.destroy.then do |user|
          state.users.remove(_user)
          set_state users: state.users
        end
      end

    end
  end
end