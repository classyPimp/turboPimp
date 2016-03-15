module Components
  module Blogs
    class Edit < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          form_model: false
        }
      end

      def component_did_mount
        id = props.params.id
        Blog.edit(wilds: {id: id}, component: self).then do |blog|
          set_state form_model: blog
        end
      end

      def render
        t(:div, {},
          spinner,
          if state.form_model
            t(:div, {className: 'blogs_edit'},
              input(Forms::Input, state.form_model, :title, {type: "text", show_name: 'title'}),
              input(Forms::Input, state.form_model, :m_title, {type: "text", show_name: 'meta title'}),
              input(Forms::Input, state.form_model, :m_description, {type: "text", show_name: 'meta desrciption'}),
              input(Forms::Input, state.form_model, :m_keywords, {type: "text", show_name: 'meta keywords'}),
              input(Forms::WysiTextarea, state.form_model, :body),
              input(Forms::Checkbox, state.form_model, :published, {checked: state.form_model.published, show_name: 'published'}),  
              t(:button, {onClick: ->{handle_inputs}}, "update blog")
            )
          end
        )
      end

      def handle_inputs
        collect_inputs
        unless state.form_model.has_errors?
          state.form_model.update(component: self).then do |model|
            if model.has_errors?
              set_state form_model: model
            else
              msg = Shared::Flash::Message.new(t(:div, {}, 
                                                t(:p, {}, "blog has been updated")
                                              ))
              Components::App::Main.instance.ref(:flash).rb.add_message(msg)
              state.form_model = model
            end
          end
        else
          set_state form_model: state.form_model
        end

      end

    end
  end
end