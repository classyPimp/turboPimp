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
            current_controll_component: Native(:div, {}).to_n,
            current_view: "month"
          }
        end

        def component_did_mount
          init_month_view
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

        def week_view(options = {})
          options[:index] = self
          Native t(Week, options)
        end

        def init_week_view(track_day)
          state.current_view = "week"
          set_state current_controll_component: ->{week_view(date: state.date)}
        end

        def init_month_view
          state.current_view = "month"
          set_state current_controll_component: ->{Native(t(Month, {ref: "month", index: self, date: state.date}))}
        end

        def init_day_view
          set_state current_controll_component: ->{Native(t(WeekDay, {ref: "day", date: state.date, index: self}))}, current_view: "day"
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

        def init_appointments_edit(appointment)
          modal_open(
            "edit",
            t(Components::Appointments::Doctors::Edit, {id: appointment.id, passed_appointment: appointment, 
                                                        on_appointment_updated: ->(a){on_appointment_updated(a)}})
          )
        end

        def current_view
          self.ref(state.current_view).rb
        end

        def delete_appointment(appointment)
          appointment.destroy(namespace: 'doctor').then do |_appointment|
            current_view.state.appointments.remove(appointment)
            current_view.set_state appointments: current_view.state.appointments
            current_view.prepare_availability if state.current_view == "day" 
          end
        end

        def on_appointment_updated(appointment)
          current_view.set_state appointments: current_view.state.appointments
          current_view.prepare_availability if state.current_view == "day" 
        end

        def on_appointment_created(appo)
          current_view.state.appointments << appo
          current_view.set_state appointments: current_view.state.appointments
          current_view.prepare_availability if state.current_view == "day" 
          modal_close
        end

      end

      class  Month < RW
        expose

        def prepare_dates
          @cur_month = props.date.clone().startOf("month")
          @first_wday = @cur_month.day()
          @track_day = @cur_month.clone().subtract((@first_wday + 1), "days")
        end

        def queries(date)
          date = @date.clone()
          date.startOf("month")
          wd = date.day() + 1
          x = {}
          z = date.subtract((wd), "days")
          x[:to] = z.clone().add(weeks: 6, days: 1).format('YYYY-MM-DD')
          x[:from] = z.format('YYYY-MM-DD')
          x
        end

        def get_initial_state
          @date = props.date
          {
            appointments: ModelCollection.new
          }
        end
  
        def component_did_mount
          Appointment.index(component: self, namespace: "doctor", payload: {from: queries(props.date)[:from], to: queries(props.date)[:to]}).then do |appointments|
            set_state appointments: appointments
          end
        end
        
        def render
          prepare_dates     
          t(:div, {},
            spinner,
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
                          t(:button, {onClick: ->{props.index.init_appointments_new(t_d_a)}}, "add appointment")
                        ),
                        t(:div, {},
                          *splat_each(fetch_appointments(@track_day.format("YYYY-MM-DD"))) do |appointment|
                            t(:span, {},
                              "#{Moment.new(appointment.start_date).format("HH:mm")} - 
                                #{Moment.new(appointment.end_date).format("HH:mm")}",
                              t(:button, {onClick: ->{props.index.init_appointments_show(appointment)}}, "show this"),
                              t(:button, {onClick: ->{props.index.init_appointments_edit(appointment)}}, "edit this"),
                              t(:button, {onClick: ->{props.index.delete_appointment(appointment)}}, "delete this"),
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

        def handle(track_day)
          props.on_init_week_view(track_day)
        end

        def prev_month 
          props.index.set_state date: (@date = props.index.state.date.subtract(1, "month"))
          component_did_mount
        end

        def next_month
          props.index.set_state date: (@date = props.index.state.date.add(1, "month"))
          component_did_mount
        end
      end

      class Week < RW
        expose

        def queries(date)
          x = {}
          date = props.date.clone().startOf("week")
          x[:from] = date.subtract(1, 'days').format('YYYY-MM-DD')
          x[:to] = date.add(8, 'days').format('YYYY-MM-DD')
          x
        end

        def get_initial_state
          {
            appointments: ModelCollection.new
          }
        end

        def component_did_mount
          Appointment.index(component: self, namespace: "doctor", payload: {from: queries(props.date)[:from], to: queries(props.date)[:to]}).then do |appointments|
            set_state appointments: appointments
          end
        end

        def fetch_appointments(t_d)
          state.appointments.where do |a|
            next if a == nil
            a.attributes[:start_date].include? "#{t_d}"
          end
        end

        def render
          t_d = @track_day = props.date.clone().subtract(1, 'days')
          t(:div, {},
            spinner,
            t(:button, {onClick: ->{prev_week}}, "<"),
            t(:button, {onClick: ->{next_week}}, ">"),
            t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"} },
              t(:div, {className: "row", style: {display: "table-row"}},
                *splat_each(Calendar.wdays) do |wday_name| 
                    t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}}, wday_name)
                end,
              ),
              t(:div, {className: "row", style: {display: "table-row"}},
                t(:div, {},#onClick: ->{handle(t_d)
                  *splat_each(0..6) do |d|
                    t_d_a = (@track_day.add(1, 'days')).clone()
                    t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}}, 
                      t(:div, {},
                        t(:span, {}, @track_day.date()),
                        t(:button, {onClick: ->{props.index.init_appointments_new(t_d_a)}}, "add appointment")
                      ),
                      t(:div, {},
                        *splat_each(fetch_appointments(@track_day.format("YYYY-MM-DD"))) do |appointment|
                          t(:span, {},
                            "#{Moment.new(appointment.start_date).format("HH:mm")} - 
                              #{Moment.new(appointment.end_date).format("HH:mm")}",
                            t(:button, {onClick: ->{props.index.init_appointments_show(appointment)}}, "show this"),
                            t(:button, {onClick: ->{props.index.init_appointments_edit(appointment)}}, "edit this"),
                            t(:button, {onClick: ->{props.index.delete_appointment(appointment)}}, "delete this"),
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
            )
          )
        end

        def prev_week 
          props.index.set_state date: (props.index.state.date.subtract(7, 'days')) 
          component_did_mount
        end

        def next_week
          props.index.set_state date: (props.index.state.date.add(7, 'days'))
          component_did_mount
        end
        
      end

      class WeekDay < RW
        expose
        #date: the moment the state is on

        def get_initial_state
          {
            appointments: ModelCollection.new,
            available: []
          }
        end

        def component_did_mount
          Appointment.index(component: self, namespace: "doctor", payload: {from: "#{props.date.format('YYYY-MM-DD')}", to: "#{props.date.clone().add(1, 'days').format('YYYY-MM-DD')}"}).then do |appointments|
            set_state appointments: appointments
            begin
            prepare_availability
          rescue Exception => e
            p e
          end
          end
        end

        def render
          t(:div, {className: "row"},
            spinner,
            t(:div, {className: "col-lg-6"},
              t(:button, {onClick: ->{prev_day}}, "<"),
              t(:button, {onClick: ->{next_day}}, ">"),
              t(:p, {}, "Today is #{props.date.format('YYYY-MM-DD HH:mm')}"),
              *splat_each(state.appointments) do |appointment|
                t(:span, {},
                  "#{Moment.new(appointment.start_date).format("HH:mm")} - 
                    #{Moment.new(appointment.end_date).format("HH:mm")}",
                  t(:button, {onClick: ->{props.index.init_appointments_show(appointment)}}, "show this"),
                  t(:button, {onClick: ->{props.index.init_appointments_edit(appointment)}}, "edit this"),
                  t(:button, {onClick: ->{props.index.delete_appointment(appointment)}}, "delete this"),
                  t(:br, {}),
                  "#{appointment.patient.profile.name}",
                  t(:br, {}),
                  "------------",
                  t(:br, {})
                )
              end
            ),
            t(:div, {className: 'col-lg-6'},
              t(:p, {}, "here ll be appointment planning for day"),
              *splat_each(state.available) do |av|
                t(:p, {}, "#{av[:start].format("HH:mm")} - #{av[:end].format("HH:mm")}")
              end
            )
          )
        end

        def prepare_availability

          state.appointments.sort! do |x, y|
            x.end_date <=> y.start_date
          end

          available = []

          data = state.appointments.data

          if data.length > 0
            x = props.date.clone().set(hour: 9, minute: 0)
            y = Moment.new(data[0].start_date)
            d = y.diff(x, 'minutes')
            p "init dif : #{d}"
            if d > 20
              available << {start: x, end: y}
            end

            0..data.length.times do |i|
              y = Moment.new(data[i].end_date)          
              if (i + 1 == data.length)
                x = y.clone().set(hour: 19, minute: 0)
              else 
                x = Moment.new(data[i + 1].start_date)
              end
              d = x.diff(y, 'minutes')
              if d >= 30
                available << {start: y, end: x}
              end
            end
          else
            available << {start: props.date.clone().set(hour: 9, minute: 0), end: props.date.clone().set(hour: 19, minute: 0)}
          end


          set_state available: available
        end

        def prev_day
          props.index.set_state date: (props.index.state.date.subtract(1, 'day'))
          component_did_mount
        end

        def next_day
          props.index.set_state date: (props.index.state.date.add(1, 'day'))
          component_did_mount
        end

      end
    end
  end
end

