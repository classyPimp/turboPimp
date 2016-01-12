module Components
  module Appointments
    class Index < RW
      expose

      def self.wdays
        ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
      end

      def get_initial_state
        {
          date: Moment.new.startOf('day'),
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

      def init_week_view(track_day)
        state.current_view = "week"
        set_state current_controll_component: ->{Native(t(Week, {ref: "week", index: self, date: state.date}))}
      end

      def init_month_view
        state.current_view = "month"
        set_state current_controll_component: ->{Native(t(Month, {ref: "month", index: self, date: state.date}))}
      end

      def init_day_view
        state.current_view = "day"
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

      #method is used and coupled to Week Month WeekDay
      #called from there by accessing through props.index, so self should be passed as index prop
      def fetch_appointments(obj, t_d)
        x = (z = obj.state.appointment_availabilities[t_d]) ? z : {}
        begining = Moment.new(t_d).set(hour: 9).format()
        ending = Moment.new(t_d).set(hour: 19).format()
        x.each do |k, v|
          v.each do |av|
            break if av.map.is_a? Array
            p_av = JSON.parse(av.map).each_slice(2).to_a.sort {|x, y| x[1] <=> y[1]} unless av.map.length == 1
            p_av.unshift([begining, begining])
            p_av.push([ending, ending])
            _map = []
            i = 0
            while i < (p_av.length - 1)
              first = Moment.new p_av[i][1]
              second = Moment.new p_av[i + 1][0]
              d = second.diff(first, "minutes")
              if d > 20
                _map << [first, second]
              end
              i += 1
            end
            av.map = _map
          end
        end 
        x
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
        date = date.clone()
        date.startOf("month")
        date = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : date 
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
          appointment_availabilities: {}
        }
      end

      def component_did_mount
        AppointmentAvailability.index(component: self, payload: queries(props.date)).then do |users|
          begin
          tree_block = lambda{|h,k| 
            if k[0] == "2"
              h[k] = Hash.new(&tree_block)
            else
              h[k] = []
            end 
          }
          opts = Hash.new(&tree_block)
          users.each do |user|
            user.appointment_availabilities.each do |av|
              opts[av.for_date][user.profile.name] << av 
            end
          end
          set_state appointment_availabilities: opts
          rescue Exception => e
            p e
          end
        end
      end
      
      def render
        prepare_dates     
        t(:div, {},
          spinner,
          t(:button, {onClick: ->{prev_month}}, "<"),
          t(:button, {onClick: ->{next_month}}, ">"),
          t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"}.to_n },
            t(:div, {className: "row", style: {display: "table-row"}.to_n },
              *splat_each(Calendar.wdays) do |wday_name| 
                  t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n}, wday_name)
              end,
            ),
            *splat_each(0..5) do |week_num|
              t_d = (@track_day).clone
              t(:div, {className: "row", style: {display: "table-row"}.to_n},
                t(:div, {},
                  *splat_each(0..6) do |d|
                    t_d_a = (@track_day.add(1, 'days')).clone()
                    t(:div, {className: "col-lg-1", style: {"height" => "12em", display: "table-cell", width: "12%", overflow: "scroll"}.to_n}, 
                      t(:div, {},
                        t(:span, {}, @track_day.date())#,
                        # t(:button, {onClick: ->{props.index.init_appointments_new(t_d_a)}}, "add appointment")
                      ),
                      t(:div, {},
                        *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |k, v|
                          t(:span, {},
                            "#{k}",
                            t(:br, {}),
                            *splat_each(v[0].map) do |av|
                              t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                            end,
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
        z = date.clone().startOf("week")
        z = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : date 
        x = {}
        x[:from] = z.format('YYYY-MM-DD')
        x[:to] = z.clone().endOf('week').format('YYYY-MM-DD')
        x
      end

      def get_initial_state
        {
          appointment_availabilities: {}
        }
      end

      def component_did_mount
        AppointmentAvailability.index(component: self, payload: queries(props.date)).then do |users|
          begin
          tree_block = lambda{|h,k| 
            if k[0] == "2"
              h[k] = Hash.new(&tree_block)
            else
              h[k] = []
            end 
          }
          opts = Hash.new(&tree_block)
          users.each do |user|
            user.appointment_availabilities.each do |av|
              opts[av.for_date][user.profile.name] << av 
            end
          end
          set_state appointment_availabilities: opts
          rescue Exception => e
            p e
          end
        end
      end

      def render
        t_d = @track_day = props.date.clone().startOf('week').subtract(1, 'days')
        t(:div, {},
          spinner,
          t(:button, {onClick: ->{prev_week}}, "<"),
          t(:button, {onClick: ->{next_week}}, ">"),
          t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"}.to_n },
            t(:div, {className: "row", style: {display: "table-row"}.to_n },
              *splat_each(Calendar.wdays) do |wday_name| 
                  t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n }, wday_name)
              end,
            ),
            t(:div, {className: "row", style: {display: "table-row"}.to_n },
              t(:div, {},
                *splat_each(0..6) do |d|
                  t_d_a = (@track_day.add(1, 'days')).clone()
                  t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n }, 
                    t(:div, {},
                      t(:span, {}, @track_day.date()),
                    ),
                    t(:div, {},
                      *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |k, v|
                        t(:span, {},
                          "#{k}",
                          t(:br, {}),
                          *splat_each(v[0].map) do |av|
                            t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                          end,
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
          appointment_availabilities: {}
        }
      end

      def component_did_mount
        AppointmentAvailability.index(component: self, payload: {from: props.date.format('YYYY-MM-DD'), to: props.date.format('YYYY-MM-DD')}).then do |users|
          begin
          tree_block = lambda{|h,k| 
            if k[0] == "2"
              h[k] = Hash.new(&tree_block)
            else
              h[k] = []
            end 
          }
          opts = Hash.new(&tree_block)
          users.each do |user|
            user.appointment_availabilities.each do |av|
              opts[av.for_date][user.profile.name] << av 
            end
          end
          set_state appointment_availabilities: opts
          rescue Exception => e
            p e
          end
        end
      end

      def render
        t(:div, {className: "row"},
          spinner,
          modal,
          t(:div, {className: "col-lg-6"},
            t(:button, {onClick: ->{prev_day}}, "<"),
            t(:button, {onClick: ->{next_day}}, ">"),
            t(:p, {}, "Today is #{props.date.format('YYYY-MM-DD HH:mm')}"),
            t(:button, {onClick: ->{init_appointments_proposals_new}}, "book an appointment for this day"),
            t(:div, {},
              *splat_each(props.index.fetch_appointments(self, props.date.clone.format("YYYY-MM-DD"))) do |k, v|
                t(:span, {},
                  "#{k}",
                  t(:br, {}),
                  *splat_each(v[0].map) do |av|
                    t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                  end,
                  "------------",
                  t(:br, {})

                )
              end
            )              
          )
        )
      end  

      def init_appointments_proposals_new
        modal_open(
          "book an appointment",
          t(Components::Appointments::Proposals::New, {date: props.date, appointment_availabilities: props.index.fetch_appointments(self, props.date.clone.format("YYYY-MM-DD"))})
        )
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

