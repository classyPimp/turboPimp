module Components
  module Dummy
    class A < RW
      expose

      def init
        @top = 0
        @left = 0
        @tooltip_counter = 0
      end

      def get_initial_state
        {
          tool_tips: {}
        }
      end

      def render
        t(:div, {}, 
          t(:button, {onClick: ->(e){open_tooltip(e)}}, 
            'press for tooltip'
          ),
          t(:p, {}, "hello"),
          *splat_each(state.tool_tips) do |k , v|
            v.call
          end
        )               
      end

      def open_tooltip(e)
        rect = Native(e).target.getBoundingClientRect()
        tp = create_tooltip(rect.bottom, rect.left)
        state.tool_tips[@tooltip_counter] = create_tooltip(rect.bottom, rect.left)
        @tooltip_counter += 1
        set_state tooltip: state.tool_tips
      end

      def create_tooltip(top, left)
        count = "#{@tooltip_counter}".to_i
        ->{t(:p, {onClick: ->{delete_tooltip(count)}, style: {position: 'absolute', top: top, left: left, zIndex: 1}.to_n}, "this is tooltip")}
      end

      def delete_tooltip(key)
        state.tool_tips.delete(key)
        set_state tool_tips: state.tool_tips
      end

    end
  end
end