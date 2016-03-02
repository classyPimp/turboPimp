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
        extra_params = {}
        (x = props.location.query.page) ? (extra_params[:page] = x) : nil
        extra_params[:per_page] = (x = props.location.query.per_page) ? x : 25
        extra_params[:search_query] = (x = props.location.query.search_query) ? x : nil
        make_query(extra_params)
      end

      def make_query(extra_params)
        @as_admin = props.as_admin ? {namespace: "admin"} : {}
        User.index({extra_params: extra_params}.merge(@as_admin)).then do |users|
          extract_pagination(users)
          set_state users: users
        end

      end

      def render
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
        User.index({extra_params: {page: _page, per_page: per_page}}.merge(@as_admin)).then do |users|
          Components::App::Router.history.replaceState(nil, props.location.pathname, {page: _page, per_page: per_page})
          extract_pagination(pages)
          set_state users: users
        end
      end

      def search
        to_search = self.ref("search").value.strip
        pathname = props.location.pathname
        query = Hash.new(props.location.query.to_n)
        query[:search_query] = to_search
        make_query(query)
        props.history.pushState(nil, pathname, query)
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