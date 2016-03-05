module Components
  module Users
    class Index < RW

      expose

      include Plugins::Formable

      include Plugins::DependsOnCurrentUser
      set_roles_to_fetch :admin

      include Plugins::Paginatable

      def get_initial_state
        {
          users: ModelCollection.new,
          per_page: props.location.query.per_page || 1,
          search_model: Model.new(roles: [])
        }
      end

      def component_did_mount

        make_query(extra_params({per_page: state.per_page}))

      end

      def extra_params(pagination_options = {})

        x = Hash.new(props.location.query.to_n)
        x = x.merge(pagination_options)
        x

      end

      # def component_will_update(next_props, ns)
      #   nx = Hash.new(`#{next_props}.location.query`)
      #   pr = Hash.new(props.location.query.to_n)
      #   if nx != pr
      #     make_query(nx)
      #   end
      # end
      # def current_location_query

      #   x = {}
      #   z = props.location.query
      #   #x[:per_page] = z.per_page
      #   #x[:page] = z.page
      #   x[:search_query] = z.search_query
      #   x[:registered_only] = z.registered_only
      #   x[:unregistered_only] = z.unregistered_only
      #   x[:chat_only] = z.chat_only
      #   x 

      # end

      def make_query(_extra_params)

        @as_admin = state.current_user.has_role?([:admin]) ? {namespace: "admin"} : {}
        p @as_admin
        User.index({extra_params: _extra_params}.merge(@as_admin)).then do |users|
          begin
          extract_pagination(users)
          set_state users: users
          rescue Exception => e
            `console.log(#{e})`
          end
        end

      end

      def render
       p state.search_model.pure_attributes

        t(:div, {className: 'row'},
          t(:div, {className: 'search'}, 
            input(Forms::Input, state.search_model, :search_query),
            input(Forms::Checkbox, state.search_model, :registered_only),
            input(Forms::Checkbox, state.search_model, :unregistered_only),
            input(Forms::Checkbox, state.search_model, :from_chat_only),
            input(Forms::Select, state.search_model, :roles, {multiple: true, server_feed: {url: "/api/users/roles_feed"},
                                                                  option_as_model: 'role', s_value: "name", show_name: ''}),
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
            t(:div, {key: state.per_page}, 
              will_paginate
            )
          end
        )
      end

      def edit_selected(user)
        url = @as_admin ? "/admin/users/#{user.id}/edit" : "/users/edit/#{user.id}"
        Components::App::Router.history.pushState({}, url)
      end

      def pagination_switch_page(_page, per_page)
        x = Hash.new(props.location.query.to_n)
        x[:page] = _page
        x[:per_page] = state.per_page
        make_query(x)
        props.history.pushState(nil, props.location.pathname, x)
        # User.index({extra_params: x.merge(@as_admin)}).then do |users|
        #   props.history.pushState(nil, props.location.pathname, x)
        #   extract_pagination(users)
        #   set_state users: users
        # end
      end

      def per_page_select(value) #from Plugins::Paginatable
        set_state per_page: value
        search(value)
      end

      def search(per_page = state.per_page)
        collect_inputs(form_model: :search_model)
        p state.search_model.pure_attributes
        # to_search = self.ref("search").value.strip
        # pathname = props.location.pathname
        # query = {}
        # query[:search_query] = to_search
        # query[:per_page] = per_page
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