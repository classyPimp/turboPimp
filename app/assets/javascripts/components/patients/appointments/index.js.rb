module Components
  module Patients
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
            current_view: "week"
          }
        end

        def component_did_mount
          init_week_view
        end  

        def render
          t(:div, {className: 'appointments_calendar'},
            modal,
            #t(MonthBox, {date: state.date, ref: 'month_box', index: self}),
            t(:h2, {className: 'view_title_date'}, "#{state.date.month() + 1}.#{state.date.year()}"),
            t(:div, {className: 'view_controlls'},
              #t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_month_view}}, "month"),
              t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_week_view(state.date.clone())}}, "week"),
              t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_day_view(state.date.clone())}}, "day"),
              t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{set_state date: Moment.new}}, "go to today"),
            ),
            t(:div, {}, 
              link_to('browse schedule and plan new appointment', '/appointments/index')
            ),
            t(:div, {},
              state.current_controll_component.to_n
            )
          )
        end

        def init_week_view(track_day)
          state.current_view = "week"
          set_state current_controll_component: ->{Native(t(Week, {ref: "week", index: self, date: state.date}))}
        end

        def current_view
          self.ref(state.current_view).rb
        end

        #method is used and coupled to Week Month WeekDay
        #called from there by accessing through props.index, so self should be passed as index prop
        def fetch_appointments(obj, t_d)
          (z = obj.state.appointments_for_dates[t_d]) ? z : {}
        end

        #builds hash and assigns appointments to date keys for further fetching through date.format()
        def prepare_availability_tree(obj, users_with_appointments)
          tree_block = lambda{|h,k| 
            if k[4] == "-"
              h[k] = Hash.new(&tree_block)
            else
              h[k] = []
            end 
          }
          opts = Hash.new(&tree_block)
          user_accessor = {}
          users_with_appointments.each do |user|
            user_accessor[user.id] = user
            user.appointments.each do |appointment|
              opts[Moment.new(appointment.start_date).format('YYYY-MM-DD')][user.id] << appointment 
            end
          end

          obj.set_state appointments_for_dates: opts, user_accessor: user_accessor

        end

      end

      class MonthBox < RW

        expose

        def prepare_dates
          @cur_month = props.date.clone().startOf("month")
          @first_wday = @cur_month.day()
          @track_day = @cur_month.clone().subtract((@first_wday + 1), "days")
          @current_week_num = `Math.ceil(#{props.date.diff(@track_day, 'days')} / 7)`
        end
        
        def render
          prepare_dates
          today = props.date.format('YYYY-MM-DD')     
          t(:div, {},
            t(:div, {className: "month_box"},
              t(:div, {className: "row week_row"},
                *splat_each(Calendar.wdays) do |wday_name| 
                    t(:div, {className: "day"}, wday_name)
                end,
              ),
              *splat_each(0..5) do |week_num|
                if week_num + 1 == @current_week_num
                  is_current = 'current_week'
                else
                  is_current = ''
                end
                t_d = (@track_day).clone
                t(:div, {className: "row week_row #{is_current}"},
                  *splat_each(0..6) do |d|
                    t_d_a = (@track_day.add(1, 'days')).clone()
                    is_today = (t_d_a.format('YYYY-MM-DD') == today) ? 'today' : ''
                    t(:div, {className: "day #{is_today}", onClick: ->{set_date(t_d_a)}}, 
                      t(:div, {},
                        t(:span, {}, @track_day.date())
                      )
                    )
                  end
                )
              end   
            )
          )
        end

        def set_date(date)
          props.index.set_state date: date
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
          x = {}
          x[:from] = z.format('YYYY-MM-DD')
          x[:to] = z.clone().endOf('week').format('YYYY-MM-DD')
          x
        end

        def get_initial_state
          {
            #appointment_availabilities: {}
            appointments_for_dates: {}
          }
        end

        def component_did_mount

          Appointment.index(component: self, payload: queries(props.date), namespace: 'patients').then do |users_with_appointments|
            begin
            props.index.prepare_availability_tree(self, users_with_appointments)
            rescue Exception => e
              p e
            end
          end
        end

        def component_did_update(prev_props, prev_state)
          if props.date.format != prev_props.date.format
            component_did_mount
          end     
        end

        def render
          passed_day = ''
          current_day = Moment.new
          t_d = @track_day = props.date.clone().startOf('week').subtract(1, 'days')
          t(:div, {},
            spinner,
            t(:div, {className: 'row'},
              t(:div, {className: 'col-lg-4'},
                t(MonthBox, {date: props.date, index: props.index})
              ),
              t(:div, {className: 'prev_next_controlls col-lg-8'}, 
                t(:button, {onClick: ->{prev_week}}, "<"),
                t(:button, {onClick: ->{next_week}}, ">"),
              ),
            ),
            t(:div, {className: 'row'},
              modal, 
              *splat_each(0..6) do |d|

                t_d_a = (@track_day.add(1, 'days')).clone()

                if @track_day.format('YYYY-MM-DD') < current_day.format('YYYY-MM-DD')
                  passed_day = 'passed'
                elsif @track_day.format('YYYY-MM-DD') == current_day.format('YYYY-MM-DD')
                  passed_day = 'today'
                else
                  passed_day = 'not_passed'
                end

                
               

                t(:div, {className: "col-lg-1 week_day_panel #{$VIEW_PORT_KIND}"},
                  t(:div, {className: "day_heading #{passed_day}"}, 
                    t(:h4, {className: 'wday_name'}, 
                      Calendar.wdays[d]
                    ),
                    t(:p, {}, @track_day.date())
                  ),
                  if passed_day == 'passed'
                    t(:div, {})
                  else

                    fetched_appointments = props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))

                    t(:div, {className: "day_body"},
                      *if !fetched_appointments.empty?
                        splat_each(fetched_appointments) do |user_id, appointments|

                          t(:div, {className: 'appointments_for_doctor'},
                            t(:img, {src: "#{state.user_accessor[user_id].avatar.url}", className: 'doctor_avatar'}),
                            t(:span, {className: 'doctor_name'}, 
                              "#{state.user_accessor[user_id].profile.name}"
                            ),
                            t(:br, {}),
                            *splat_each(appointments) do |av|
                              t(:p, {className: 'doctor_appointment'}, "#{Moment.new(av.start_date).format('HH:mm')} - #{Moment.new(av.end_date).format('HH:mm')}", t(:br, {}))
                            end,
                            t(:br, {})
                          )
                        end                     
                      end
                    )
                  end
                )
              end
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

      
    end
  end
end