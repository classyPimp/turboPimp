module Components
  module Users

  	class Show < RW
  		expose
      def get_initial_state
        {
          user: false
        }
      end

      def component_did_mount
        #by default component will fetch usr based on url wild param :id
        #in order for it to be non url based props.user_id must be passed
        #if passed props.user_id will fetch that user id
        user_id = props.user_id ? props.user_id : props.params.id
        User.show(wilds: {id: user_id}).then do |user|
          set_state user: user
        end.fail do |response|
          `console.log("error:")`
          `console.log(#{response})`
        end
      end

  		def render
  			t(:div, {},
          if state.user
            t(:div, {}, 
              t(:p, {}, (state.message if state.message)),
      				t(:div, {},
                t(:div, {},
                  t(:image, {src: "#{state.user.try(:avatar).try(:url)}", style: {width: "100px", height: "100px"}.to_n }, )
                ),
                t(:p, {}, "name: #{state.user.try(:profile).try(:name)}"),
                t(:p, {}, "email: #{state.user.email}"),
                t(:p, {}, "bio: #{state.user.try(:profile).try(:bio)}")
              ),
              if state.user.attributes[:arbitrary] == "current_user"
                t(:div, {},
                  t(:a, {onClick: ->(){logout_user}, style: {cursor: "pointer"}.to_n }, "click here to logout"),
                  t(:br, {}),
                  link_to("edit my account data", "/users/#{state.user.id}/edit")
                )
              end
            )
          end
  			)
  		end

      def logout_user
        AppController.logout_user
      end

  	end

  end
end