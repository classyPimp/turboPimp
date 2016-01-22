module Components
  module Appointments 
    module AppointmentSchedulers
      class Index < RW

        expose

        include Plugins::Formable

        def self.wdays
          ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
        end

        def get_initial_state
          doctor_ids = props.uniq_profiles.keys
          date = Moment.new(props.date).startOf('day')
          {
            date: date,
            current_controll_component: Native(:div, {}).to_n,
            current_view: "day",
            doctor_ids: doctor_ids,
            doctor_ids_holder: Model.new(doctors: props.uniq_profiles.values)
          }
        end

        def component_did_mount
          init_day_view
        end

        def render
          t(:div, {},
            modal,
            t(:div, {className: 'row'},
              t(:div, {className: 'col-lg-6'},
                t(:p, {}, "the month is #{state.date.month() + 1}, of year #{state.date.year()}"),
                t(:button, {onClick: ->{init_month_view}}, "month"),
                t(:button, {onClick: ->{init_week_view(state.date.clone())}}, "week"),
                t(:button, {onClick: ->{init_day_view}}, "day"),
                t(:button, {onClick: ->{set_state date: Moment.new}}, "go to today"),
                t(:br, {}),
                input(Forms::Select, state.doctor_ids_holder, :doctors, {multiple: true, s_value: 'name',  
                  option_as_model: true, server_feed: {url: "/api/doctor/users/doctors_feed"}, namespace: 'doctors_select'}, destroy: false),
                t(:button, { onClick: ->{refine_doctor_ids} }, 'update with choesen doctors')
              ),
              t(:div, {className: 'col-lg-6'},
                t(Components::Appointments::AppointmentSchedulers::Partials::DesiredAppointments, {appointment_proposal_infos: props.appointment.appointment_proposal_infos})
              ) 
            ),
            t(:div, {},
              state.current_controll_component.to_n
            )
          )
        end

        def refine_doctor_ids
          collect_inputs(namespace: 'doctors_select', validate: false)
          ids = [] 
          state.doctor_ids_holder.attributes[:doctors].each do |profile|
            ids << profile.user_id
          end
          state.doctor_ids = ids
          ref(state.current_view).rb.component_did_mount
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

        def current_view
          self.ref(state.current_view).rb
        end

        #method is used and coupled to Week Month WeekDay
        #called from there by accessing through props.index, so self should be passed as index prop
        def fetch_appointments(obj, t_d)
          users = (z = obj.state.appointments_for_dates[t_d]) ? z : {}
          users
        end

        def prepare_appointments_tree(obj, users)
          tree_block = lambda{ |h, k| 
            if k[0] == "2"
              h[k] = Hash.new(&tree_block)
            else
              h[k] = []
            end
          }
          opts = Hash.new(&tree_block)
          users.each do |user|
            user.appointments.each do |appointment|
              opts[Moment.new(appointment.start_date).format('YYYY-MM-DD')][user.profile.name] << appointment 
            end
          end
          obj.set_state appointments_for_dates: opts
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
            appointments_for_dates: {}
          }
        end

        def component_did_mount
          Appointment.index(component: self, payload: queries(props.date).merge(doctor_ids: props.index.state.doctor_ids), namespace: 'appointment_scheduler').then do |users|
            props.index.prepare_appointments_tree(self, users) 
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
                          t(:span, {}, @track_day.date())
                        ),
                        t(:div, {},
                          *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |user_name, appointments|
                            t(:div, {},
                              t(:p, {}, user_name),
                              *splat_each(appointments) do |appointment|
                                t(:div, {},
                                  t(:p, {}, "#{Moment.new(appointment.start_date).format('HH:mm')} : #{Moment.new(appointment.end_date).format('HH:mm')}")
                                )
                              end
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
            appointments_for_dates: {}
          }
        end

        def component_did_mount
          Appointment.index(component: self, payload: queries(props.date).merge(doctor_ids: props.index.state.doctor_ids), namespace: 'appointment_scheduler').then do |users|
            props.index.prepare_appointments_tree(self, users) 
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
                        *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |user_name, appointments|
                          t(:div, {},
                            t(:p, {}, user_name),
                            *splat_each(appointments) do |appointment|
                              t(:div, {},
                                t(:p, {}, "#{Moment.new(appointment.start_date).format('HH:mm')} : #{Moment.new(appointment.end_date).format('HH:mm')}")
                              )
                            end
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
            appointments_for_dates: {}
          }
        end

        def component_did_mount
          Appointment.index(component: self, payload: {doctor_ids: props.index.state.doctor_ids, from: props.date.clone.startOf('day').format(), to: props.date.clone.endOf('day').format()}, namespace: 'appointment_scheduler').then do |users|
            props.index.prepare_appointments_tree(self, users) 
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
              t(:button, { onClick: ->{ init_appointments_appointment_schedulers_new_from_proposal } }, 'schedule for this date'),
              t(:div, {},
                *splat_each(props.index.fetch_appointments(self, props.date.clone.format("YYYY-MM-DD"))) do |user_name, appointments|
                  t(:div, {},
                    t(:p, {}, user_name),
                    *splat_each(appointments) do |appointment|
                      t(:div, {},
                        t(:p, {}, "#{Moment.new(appointment.start_date).format('HH:mm')} : #{Moment.new(appointment.end_date).format('HH:mm')}")
                      )
                    end
                  )                  
                end
              )              
            )
          )
        end

        def init_appointments_appointment_schedulers_new_from_proposal
          modal_open(
            'schedule',
            t(Components::Appointments::AppointmentSchedulers::NewFromProposal, {date: props.date.clone, appointment: props.index.props.appointment} )
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
end

