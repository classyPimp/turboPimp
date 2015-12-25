require "date"
module Components
  module Appointments
    module Doctors
      class Index < RW
        expose

        def self.wdays
          ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
        end

        attr_accessor :controll_date

        def get_initial_state
          {
            date: Date.today,
            current_controll_component: ->{month_view}
          }
        end

        def render
          t(:div, {},
            modal,
            t(:p, {}, "the month is #{state.date.month}, of year #{state.date.year}"),
            t(:button, {onClick: ->{init_month_view}}, "month"),
            t(:button, {onClick: ->{init_week_view(state.date)}}, "week"),
            t(:button, {onClick: ->{init_day_view}}, "day"),
            t(:button, {onClick: ->{set_state date: Date.today}}, "go to today"),
            t(:br, {}),
            t(:div, {},
              state.current_controll_component.to_n
            )
          )
        end

        def month_view
          options = {index: self, date: state.date, on_init_week_view: ->(track_day){init_week_view(track_day)}}
          Native(t(Month, options))
        end

        def week_view(options = {})
          options[:index] = self
          Native t(Week, options)
        end

        def init_week_view(track_day)
          state.date = track_day
          set_state current_controll_component: ->{week_view(track_day: state.date)}
        end

        def init_month_view
          set_state current_controll_component: ->{month_view}
        end

        def init_day_view
          set_state current_controll_component: ->{Native(t(WeekDay, {date: state.date, index: self}))}
        end

        def init_appointment_new(date)
          modal_open(
            nil,
            t(Components::Appointments::Doctors::New, {date: date})
          )
        end

      end

      class  Month < RW
        expose
        
        def render
          #@ev_feed = Eventy.prepare(state.events_feed)
          @cur_month = props.date - (props.date.day - 1)
          @first_wday = @cur_month.wday
          @track_day = @cur_month.clone - (@first_wday + 1)

          t(:div, {},
            t(:button, {onClick: ->{prev_month}}, "<"),
            t(:button, {onClick: ->{next_month}}, ">"),
            t(:div, {className: "table"},
              t(:div, {className: "row"},
                t(:div, {className: "col-lg-2"}),
                *splat_each(Calendar.wdays) do |wday_name| 
                    t(:div, {className: "col-lg-1"}, wday_name)
                end,
                t(:div, {className: "col-lg-3"})
              ),
              *splat_each(0..5) do |week_num|
                t_d = (@track_day).clone
                t(:div, {className: "row"},
                  t(:div, {className: "col-lg-2"}),
                  t(:div, {},#onClick: ->{handle(t_d)
                    *splat_each(0..6) do |d|
                      t_d_a = (@track_day + 1)
                      t(:div, {className: "col-lg-1", style: {"height" => "6em"}}, 
                        t(:div, {style: {display: "inline"}},
                          t(:span, {}, (@track_day += 1).day),
                          t(:span, {onClick: ->{init_appointment_new(t_d_a)}}, "add appointment")
                        )
                        # *splat_each(0..6) do |x|
                        #   z = "#{@track_day.year}-#{@track_day.month}-#{@track_day.day}"
                        #   val = @ev_feed[z].pop if @ev_feed[z]
                        #   t(:p, {}, val ? "#{val.start} - #{val.finish}" : "")
                        # end
                      )
                    end
                  ),
                  t(:div, {className: "col-lg-3"})
                )
              end   
            )
          )
        end

        def init_appointment_new(date)
          props.index.init_appointment_new(date)
        end

        def handle(track_day)
          props.on_init_week_view(track_day)
        end

        def prev_month 
          props.index.set_state date: props.index.state.date.prev_month
        end

        def next_month
          props.index.set_state date: props.index.state.date.next_month
        end
      end

      class Week < RW
        expose

        def render
          @track_day = props.track_day.clone

          t(:div, {},
            t(:button, {onClick: ->{prev_week}}, "<"),
            t(:button, {onClick: ->{next_week}}, ">"),
            t(:table, {},
              t(:tbody, {},
                t(:tr, {},
                  *splat_each(Calendar.wdays) do |wday_name| 
                      t(:th, {}, wday_name)
                  end
                ),
                t(:tr, {},
                  *splat_each(0..6) do |wday_num|
                    t(:td, {}, (@track_day += 1).day)
                  end
                )
              )     
            )
          )
        end

        def prev_week 
          props.index.set_state date: (props.index.state.date - 7) 
        end

        def next_week
          props.index.set_state date: (props.index.state.date + 7)
        end
        
      end

      class WeekDay < RW
        expose

        def render
          t(:div, {},
            t(:button, {onClick: ->{prev_day}}, "<"),
            t(:button, {onClick: ->{next_day}}, ">"),
            t(:p, {}, "Today is #{props.date}"),
            t(:input, {type: "date", ref: "foo"}),
            t(:button, {onClick: ->{alert(ref(:foo).value)}}, "select date")

          )
        end

        def prev_day
          props.index.set_state date: (props.index.state.date - 1)  
        end

        def next_day
          props.index.set_state date: (props.index.state.date + 1)
        end

      end
    end
  end
end
