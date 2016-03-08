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
          search_model: User.new,
          disabled_inputs: {registered_only: false, unregistered_only: false}
        }
      end

      def component_did_mount
        x = Hash.new(props.location.query.to_n)
        unless x.empty?
          make_query(x)
        end
      end

      def component_will_receive_props(next_props)
        n_q = Hash.new(Native(next_props).location.query.to_n)
        c_q = Hash.new(props.location.query.to_n)  
        if n_q != c_q
          make_query(n_q)
        end      
      end

      def make_query(_extra_params)

        @as_admin = state.current_user.has_role?([:admin]) ? {namespace: "admin"} : {}
        _extra_params[:per_page] = _extra_params[:per_page] || props.location.query.per_page || 1
        User.index({extra_params: _extra_params, component: self}.merge(@as_admin)).then do |users|
          begin
          extract_pagination(users)
          set_state users: users
          rescue Exception => e
            `console.log(#{e})`
          end
        end

      end

      def render

        t(:div, {className: 'row admin_user_index'},
          spinner,
          t(:div, {className: 'row search'}, 
            t(:div, {className: 'search_bar'}, 
              input(Forms::Input, state.search_model, :search_query, {show_name: 'search', className: 'form-control'})
            ),
            unless state.disabled_inputs[:registered_only]
              input(Forms::Checkbox, state.search_model, :registered_only, {show_name: 'search only registered users' ,to_call_on_change: event(->{disable_inputs([:unregistered_only])})})
            end,
            unless state.disabled_inputs[:unregistered_only]
              input(Forms::Checkbox, state.search_model, :unregistered_only, {show_name: 'search only unregistered users' , to_call_on_change: event(->{disable_inputs([:registered_only])})})
            end,

            input(Forms::Checkbox, state.search_model, :from_chat_only, {show_name: 'search users coming from chat'}),

            t(:p, {}, 'search users who have this rights'),
            input(Forms::Select, state.search_model, :roles, {multiple: true, server_feed: {url: "/api/users/roles_feed"},
                                                                  option_as_model: 'role', s_value: "name", show_name: ''}),
            t(:button, {onClick: ->{search}}, "search!")
          ),
          t(:div, {className: 'search_results row'},
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
        
      end

      def per_page_select(value) #from Plugins::Paginatable
        c_q = Hash.new(props.location.query.to_n)
        c_q[:per_page] = value
        c_q[:page] = 1
        props.history.pushState(nil, props.location.pathname, c_q)
      end

      def search(per_page = state.per_page)
        collect_search_hash
        # to_search = self.ref("search").value.strip
        # pathname = props.location.pathname
        # query = {}
        # query[:search_query] = to_search
        # query[:per_page] = per_page
        # make_query(query)
        # props.history.pushState(nil, pathname, query)
      end

      def collect_search_hash()
        collect_inputs(form_model: :search_model)
        roles = []
        m = state.search_model
        m.roles.each do |role|
          roles << role.name
        end

        ex_p = m.pure_attributes[:user]
        ex_p.delete(:roles_attributes)
        ex_p[:roles] = roles
        ex_p[:per_page] = props.location.query.per_page || 1

        props.history.pushState(nil, props.location.pathname, ex_p)
        #make_query(ex_p)
      
      end

      def disable_inputs(ar)
        ar.each do |el|
          state.disabled_inputs[el] = !state.disabled_inputs[el]  
        end
        set_state disabled_inputs: state.disabled_inputs
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