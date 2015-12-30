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
            date: Moment.new,
            current_controll_component: ->{month_view},
            current_view: "month"
          }
        end

        def render
          t(:div, {},
            modal,
            t(:p, {}, "the month is #{state.date.month() + 1}, of year #{state.date.year()}"),
            t(:button, {onClick: ->{init_month_view}}, "month"),
            t(:button, {onClick: ->{init_week_view(state.date.clone())}}, "week"),
            t(:button, {onClick: ->{init_day_view}}, "day"),
            t(:button, {onClick: ->{set_state date: Moment.new}}, "go to today"),
            t(:br, {}),
            t(:div, {},
              state.current_controll_component.to_n
            )
          )
        end

        def month_view
          options = {on_init_appointments_show: ->(appointment){init_appointments_show(appointment)}, ref: "month", index: self, date: state.date, on_init_week_view: ->(track_day){init_week_view(track_day)}}
          Native(t(Month, options))
        end

        def week_view(options = {})
          options[:index] = self
          Native t(Week, options)
        end

        def init_week_view(track_day)
          state.current_view = "week"
          state.date = track_day
          set_state current_controll_component: ->{week_view(track_day: state.date)}
        end

        def init_month_view
          state.current_view = "month"
          set_state current_controll_component: ->{month_view}
        end

        def init_day_view
          state.current_view = "day"
          set_state current_controll_component: ->{Native(t(WeekDay, {date: state.date, index: self}))}
        end

        def init_appointments_new(date)
          modal_open(
            "create appointment",
            t(Components::Appointments::Doctors::New, {date: date, on_appointment_created: ->(appo){self.on_appointment_created(appo)}})
          )
        end

        def init_appointments_show(appointment)
          modal_open(
            "appointment",
            t(Components::Appointments::Doctors::Show, {appointment: appointment})
          )
        end

        def init_appointments_edit(id)
          modal_open(
            "edit",
            t(Components::Appointments::Doctors::Edit, {id: id})
          )
        end

        def on_appointment_created(appo)
          (x = ref(state.current_view).rb).state.appointments << appo
          x.set_state appointments: x.state.appointments
          modal_close
        end

      end

      class  Month < RW
        expose

        def prepare_dates
          @cur_month = props.date.clone().startOf("month")
          @first_wday = @cur_month.day()
          @track_day = @cur_month.clone().subtract((@first_wday + 1), "days")
          @start_to_query = @track_day.clone().add(1, "days")
        end

        def get_initial_state
          {
            appointments: ModelCollection.new
          }
        end
  
        def component_did_mount
          Appointment.index(namespace: "doctor", payload: {from: "#{@start_to_query.format('YYYY-MM-DD')}", to: "#{@track_day.format('YYYY-MM-DD')}"}).then do |appointments|
            set_state appointments: appointments
          end
        end
        
        def render
          prepare_dates       
          t(:div, {},
            t(:button, {onClick: ->{prev_month}}, "<"),
            t(:button, {onClick: ->{next_month}}, ">"),
            t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"} },
              t(:div, {className: "row", style: {display: "table-row"}},
                *splat_each(Calendar.wdays) do |wday_name| 
                    t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}}, wday_name)
                end,
              ),
              *splat_each(0..5) do |week_num|
                t_d = (@track_day).clone
                t(:div, {className: "row", style: {display: "table-row"}},
                  t(:div, {},#onClick: ->{handle(t_d)
                    *splat_each(0..6) do |d|
                      t_d_a = (@track_day.add(1, 'days')).clone()
                      t(:div, {className: "col-lg-1", style: {"height" => "12em", display: "table-cell", width: "12%", overflow: "scroll"}}, 
                        t(:div, {},
                          t(:span, {}, @track_day.date()),
                          t(:button, {onClick: ->{init_appointment_new(t_d_a)}}, "add appointment")
                        ),
                        t(:div, {},
                          *splat_each(fetch_appointments(@track_day.format("YYYY-MM-DD"))) do |appointment|
                            t(:span, {},
                              "#{Moment.new(appointment.start_date).format("HH:mm")} - 
                                #{Moment.new(appointment.end_date).format("HH:mm")}",
                              t(:button, {onClick: ->{props.on_init_appointments_show(appointment)}}, "show this"),
                              t(:button, {onClick: ->{props.index.init_appointments_edit(appointment.id)}}, "edit this"),
                              t(:button, {}, "delete this"),
                              t(:br, {}),
                              "#{appointment.patient.profile.name}",
                              t(:br, {}),
                              "------------",
                              t(:br, {})

                            )
                          end
                        )             
                      )
                    end
                  )
                )
              end   
            )
          )
        end

        def fetch_appointments(t_d)
          state.appointments.where do |a|
            next if a == nil
            a.attributes[:start_date].include? "#{t_d}"
          end
        end

        def init_appointment_new(date)
          props.index.init_appointments_new(date)
        end

        def handle(track_day)
          props.on_init_week_view(track_day)
        end

        def prev_month 
          props.index.set_state date: props.index.state.date.subtract(1, "month")
        end

        def next_month
          props.index.set_state date: props.index.state.date.add(1, "month")
        end
      end

      class Week < RW
        expose

        def render
          @track_day = props.track_day.clone().startOf('week')

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
                    t(:td, {}, (@track_day.add(1, 'days')).date())
                  end
                )
              )     
            )
          )
        end

        def prev_week 
          props.index.set_state date: (props.index.state.date.subtract(7, 'days')) 
        end

        def next_week
          props.index.set_state date: (props.index.state.date.add(7, 'days'))
        end
        
      end

      class WeekDay < RW
        expose

        def render
          t(:div, {},
            t(:button, {onClick: ->{prev_day}}, "<"),
            t(:button, {onClick: ->{next_day}}, ">"),
            t(:p, {}, "Today is #{props.date.format('YYYY-MM-DD HH:mm')}"),
            t(:input, {type: "date", ref: "foo"}),
            t(:button, {onClick: ->{alert(ref(:foo).value)}}, "select date")

          )
        end

        def prev_day
          props.index.set_state date: (props.index.state.date.subtract(1, 'day'))  
        end

        def next_day
          props.index.set_state date: (props.index.state.date.add(1, 'day'))
        end

      end
    end
  end
end

