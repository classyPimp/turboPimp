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

        extra_params = Hash.new(props.location.query.to_n)
        make_query(extra_params)
      end

      def component_did_update
        
      end

      def current_location_query

        x = {}
        z = props.location.query
        #x[:per_page] = z.per_page
        #x[:page] = z.page
        x[:search_query] = z.search_query
        x[:registered_only] = z.registered_only
        x[:unregistered_only] = z.unregistered_only
        x[:chat_only] = z.chat_only
        x 

      end

      def make_query(extra_params)
        @as_admin = props.as_admin ? {namespace: "admin"} : {}
        User.index({extra_params: extra_params}.merge(@as_admin)).then do |users|
          begin
          extract_pagination(users)
          set_state users: users
          rescue Exception => e
            `console.log(#{e})`
          end
        end

      end

      def render
        p Hash.new(props.location.query.to_n)
        
        t(:div, {className: 'row'},
          t(:div, {className: 'search'}, 
            t(:input, {ref: "search"}),
            t(:button, {onClick: ->{search}}, "search!")
          ),
          t(:div, {className: 'users_index row'},
            *splat_each(state.users) do |user|
              t(:div, {className: 'user_box col-lg-5'},
                if user.avatar 
                  t(:image, {src: user.avatar.url, className: 'avatar'})
                end,
                t(:p, {},"email: #{user.email}"),
                t(:p, {}, (link_to("name: #{user.profile.name}", "/users/show/#{user.id}" ) if user.profile) ),
                if state.current_user.has_role? :admin
                  t(:div, {},  
                    unless user.roles.empty?
                      t(:p, {className: 'roles'}, "rights:", 
                        *splat_each(user.roles) do |role|
                          t(:span, {className: "label label-default"}, role.name)
                        end
                      )
                    end,
                    t(:button, {onClick: ->{edit_selected(user)}, className: 'btn btn-default' }, "edit user"),
                    t(:button, {onClick: ->{destroy_selected(user)}, className: 'btn btn-default'}, "delete user")
                  )
                end     
              )
            end
          ),
          unless state.users.data.empty?
            will_paginate
          end
        )
      end

      def edit_selected(user)
        url = @as_admin ? "/admin/users/#{user.id}/edit" : "/users/edit/#{user.id}"
        Components::App::Router.history.pushState({}, url)
      end

      def pagination_switch_page(_page, per_page)
        # x = current_location_query
        # x[:page] = _page
        # x[:per_page] = per_page
        # User.index({extra_params: x.merge(@as_admin)}).then do |users|
        #   props.history.pushState(nil, props.location.pathname, x)
        #   extract_pagination(users)
        #   set_state users: users
        # end
      end

      def on_pere_page_select
        
      end

      def search
        # to_search = self.ref("search").value.strip
        # pathname = props.location.pathname
        # query = Hash.new(props.location.query.to_n)
        # query[:search_query] = to_search
        # make_query(query)
        # props.history.pushState(nil, pathname, query)
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