module Components
  module Appointments
    module Doctors
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
              state.current_controll_component.to_n
            )
          )
        end

        def init_week_view(track_day)
          state.current_view = "week"
          set_state current_controll_component: ->{Native(t(Week, {ref: "week", index: self, date: state.date}))}
        end

        # def init_month_view
        #   state.current_view = "month"
        #   set_state current_controll_component: ->{Native(t(Month, {ref: "month", index: self, date: state.date}))}
        # end

        def init_day_view(day)
          state.current_view = "day"
          state.date = day
          set_state date: state.date,current_controll_component: ->{Native(t(WeekDay, {ref: "day", date: state.date, index: self}))}, current_view: "day"
        end

        def current_view
          self.ref(state.current_view).rb
        end

        #method is used and coupled to Week Month WeekDay
        #called from there by accessing through props.index, so self should be passed as index prop
        # def fetch_appointments(obj, t_d)
        #   x = (z = obj.state.appointment_availabilities[t_d]) ? z : {}
        #   begining = Moment.new(t_d).set(hour: 9).format()
        #   ending = Moment.new(t_d).set(hour: 19).format()
        #   x.each do |k, v|
        #     v.each do |av|
        #       break if av.map.is_a? Array
        #       p_av = JSON.parse(av.map).each_slice(2).to_a.sort {|x, y| x[1] <=> y[1]} unless av.map.length == 1
        #       p_av.unshift([begining, begining])
        #       p_av.push([ending, ending])
        #       _map = []
        #       i = 0
        #       while i < (p_av.length - 1)
        #         first = Moment.new p_av[i][1]
        #         second = Moment.new p_av[i + 1][0]
        #         d = second.diff(first, "minutes")
        #         if d > 20
        #           _map << [first, second]
        #         end
        #         i += 1
        #       end
        #       av.map = _map
        #     end
        #   end 
        #   x
        # end

        # def prepare_availability_tree(obj, users)
        #   tree_block = lambda{|h,k| 
        #     if k[0] == "2"
        #       h[k] = Hash.new(&tree_block)
        #     else
        #       h[k] = []
        #     end 
        #   }
        #   opts = Hash.new(&tree_block)
        #   user_accessor = {}
        #   users.each do |user|
        #     user_accessor[user.id] = user
        #     user.appointment_availabilities.each do |av|
        #       opts[av.for_date][user.id] << av 
        #     end
        #   end
        #   obj.set_state appointment_availabilities: opts, user_accessor: user_accessor
        # end

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

      # class  Month < RW
      #   expose

      #   def prepare_dates
      #     @cur_month = props.date.clone().startOf("month")
      #     @first_wday = @cur_month.day()
      #     @track_day = @cur_month.clone().subtract((@first_wday + 1), "days")
      #   end

      #   def queries(date)
      #     date = date.clone()
      #     date.startOf("month")
      #     date = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : date 
      #     wd = date.day() + 1
      #     x = {}
      #     z = date.subtract((wd), "days")
      #     x[:to] = z.clone().add(weeks: 6, days: 1).format('YYYY-MM-DD')
      #     x[:from] = z.format('YYYY-MM-DD')
      #     x
      #   end

      #   def get_initial_state
      #     @date = props.date
      #     {
      #       appointment_availabilities: {}
      #     }
      #   end

      #   def component_did_mount
      #     AppointmentAvailability.index(component: self, payload: queries(props.date)).then do |users|
      #       props.index.prepare_availability_tree(self, users)
      #     end
      #   end
        
      #   def render
      #     prepare_dates     
      #     t(:div, {},
      #       spinner,
      #       t(:button, {onClick: ->{prev_month}}, "<"),
      #       t(:button, {onClick: ->{next_month}}, ">"),
      #       t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"}.to_n },
      #         t(:div, {className: "row", style: {display: "table-row"}.to_n },
      #           *splat_each(Calendar.wdays) do |wday_name| 
      #               t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n}, wday_name)
      #           end,
      #         ),
      #         *splat_each(0..5) do |week_num|
      #           t_d = (@track_day).clone
      #           t(:div, {className: "row", style: {display: "table-row"}.to_n},
      #             t(:div, {},
      #               *splat_each(0..6) do |d|
      #                 t_d_a = (@track_day.add(1, 'days')).clone()
      #                 t(:div, {className: "col-lg-1", style: {"height" => "12em", display: "table-cell", width: "12%", overflow: "scroll"}.to_n}, 
      #                   t(:div, {},
      #                     t(:span, {}, @track_day.date())
      #                   ),
      #                   t(:div, {},
      #                     *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |k, v|
      #                       t(:span, {},
      #                         "#{k}",
      #                         t(:br, {}),
      #                         *splat_each(v[0].map) do |av|
      #                           t(:span, {}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
      #                         end,
      #                         "------------",
      #                         t(:br, {})

      #                       )
      #                     end
      #                   )             
      #                 )
      #               end
      #             )
      #           )
      #         end   
      #       )
      #     )
      #   end

      #   def prev_month 
      #     props.index.set_state date: (@date = props.index.state.date.subtract(1, "month"))
      #     component_did_mount
      #   end

      #   def next_month
      #     props.index.set_state date: (@date = props.index.state.date.add(1, "month"))
      #     component_did_mount
      #   end
      # end

      class Week < RW
        expose

        def queries(date)
          p date.format
          z = date.clone().startOf("week")
          z = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : z 
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
          Appointment.index(component: self, namespace: "doctor", payload: {from: queries(props.date)[:from], to: queries(props.date)[:to], doctor_ids: [CurrentUser.user_instance.id]}).then do |appointments|
            set_state appointments: appointments
          end

          # AppointmentAvailability.index(component: self, payload: queries(props.date)).then do |users|
          #   props.index.prepare_availability_tree(self, users)
          # end
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
            t(:div, {className: 'prev_next_controlls'}, 
              t(:button, {onClick: ->{prev_week}}, "<"),
              t(:button, {onClick: ->{next_week}}, ">"),
            ),

            t(:div, {className: 'row'},
              modal, 
              t(:div, {className: "col-lg-1 week_day_panel #{$VIEW_PORT_KIND}"},
                t(MonthBox, {date: props.date, index: props.index})
              ),
              *splat_each(0..6) do |d|

                t_d_a = (@track_day.add(1, 'days')).clone()

                # if @track_day.format('YYYY-MM-DD') < current_day.format('YYYY-MM-DD')
                #   passed_day = 'passed'
                # elsif @track_day.format('YYYY-MM-DD') == current_day.format('YYYY-MM-DD')
                #   passed_day = 'today'
                # else
                #   passed_day = 'not_passed'
                # end

                
                # if passed_day != 'passed'
                #   go_to_day_event = {onClick: ->{props.index.init_day_view(t_d_a)}}
                # else
                #   go_to_day_event = {}
                # end

                t(:div, {className: "col-lg-1 week_day_panel #{$VIEW_PORT_KIND}"},
                  t(:div, {className: "day_heading #{passed_day}"}.merge(go_to_day_event), 
                    t(:h4, {className: 'wday_name'}, 
                      Calendar.wdays[d]
                    ),
                    t(:p, {}, @track_day.date())
                  ),
                  # if passed_day == 'passed'
                  #   t(:div, {})
                  # else

                    fetched_appointments = fetch_appointments(@track_day.format("YYYY-MM-DD"))#props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))


                    t(:div, {className: "day_body"},
                      # t(:button, {className: 'init_appointment_btn btn btn-success center-block', onClick: ->{init_appointments_proposals_new(t_d_a)}},
                      #   'book appointment for this day'
                      # ),
                      # *if fetched_appointments.empty?
                      #   t(:p, {className: 'any_time_appointment'}, 'there are appointments available for this day')
                      # else
                        *splat_each(fetched_appointments) do |appointment|
                          t(:div, {className: 'appointments_for_doctor'},
                            
                            #t(:img, {src: "#{state.user_accessor[k].avatar.url}", className: 'doctor_avatar'}),
                            # t(:span, {className: 'doctor_name'}, 
                            #   "#{state.user_accessor[k].profile.name}"
                            # ),
                            #t(:br, {}),
                            # *splat_each(v[0].map) do |av|
                            #   t(:p, {className: 'doctor_appointment'}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                            # end,
                            # t(:br, {})
                          )
                        end                     
                      # end
                    )
                  # end
                )
              end
            )
          )
        end

        def init_appointments_proposals_new(date)
          modal_open(
            "book an appointment",
            t(Components::Appointments::Proposals::New, {date: date, appointment_availabilities: props.index.fetch_appointments(self, date.clone.format("YYYY-MM-DD")), user_accessor: state.user_accessor, on_appointment_proposal_created: event(->{modal_close})})
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
            props.index.prepare_availability_tree(self, users)
          end
        end

        def render
          fetched_appointments = props.index.fetch_appointments(self, props.date.format("YYYY-MM-DD"))

          t(:div, {className: "row "},
            spinner,
            modal,
            t(:div, {className: "col-lg-3"},
              t(MonthBox, {date: props.date, index: props.index})
            ),
            t(:div, {className: "col-lg-6 day_panel"},
              t(:div, {className: 'prev_next_controlls'},
                t(:button, {onClick: ->{prev_day}}, "<"),
                t(:button, {onClick: ->{next_day}}, ">"),
              ),
              t(:div, {className: "day_heading"}, 
                t(:h4, {className: 'wday_name'}, 
                  Calendar.wdays[props.date.day()]
                ),
                t(:p, {}, props.date.format('DD'))
              ),
              t(:div, {className: "day_body"},
                t(:button, {className: 'init_appointment_btn btn btn-success center-block', onClick: ->{init_appointments_proposals_new(props.date)}},
                  'book appointment for this day'
                ),
                *if fetched_appointments.empty?
                  t(:p, {className: 'any_time_appointment'}, 'there are appointments available for this day')
                else
                  
                  splat_each(fetched_appointments) do |k, v|
                    t(:div, {className: 'appointments_for_doctor'},
                      t(:img, {src: "#{state.user_accessor[k].avatar.url}", className: 'doctor_avatar'}),
                      t(:span, {className: 'doctor_name'}, 
                        "#{state.user_accessor[k].profile.name}"
                      ),
                      t(:br, {}),
                      *splat_each(v[0].map) do |av|
                        t(:p, {className: 'doctor_appointment'}, "#{av[0].format('HH:mm')} - #{av[1].format('HH:mm')}", t(:br, {}))
                      end,
                      t(:br, {})
                    )
                  end
                  
                end
              )
            ),
            t(:div, {className: 'col-lg-3'})
          )
        end  

        def init_appointments_proposals_new(date)
          modal_open(
            "book an appointment",
            t(Components::Appointments::Proposals::New, {date: date, appointment_availabilities: props.index.fetch_appointments(self, date.clone.format("YYYY-MM-DD")), user_accessor: state.user_accessor, on_appointment_proposal_created: event(->{modal_close})})
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
      # class Index < RW
      #   expose

      #   def self.wdays
      #     ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
      #   end

      #   def get_initial_state
      #     {
      #       date: Moment.new,
      #       current_controll_component: 'div',
      #       current_view: "week"
      #     }
      #   end

      #   def component_did_mount
      #     init_week_view
      #   end

      #   def render
      #     t(:div, {},
      #       modal,
      #       t(:p, {}, "the month is #{state.date.month() + 1}, of year #{state.date.year()}"),
      #       t(:button, {onClick: ->{init_month_view}}, "month"),
      #       t(:button, {onClick: ->{init_week_view(state.date.clone())}}, "week"),
      #       t(:button, {onClick: ->{init_day_view}}, "day"),
      #       t(:button, {onClick: ->{set_state date: Moment.new}}, "go to today"),
      #       t(:br, {}),
      #       t(:div, {},
      #         state.current_controll_component.to_n
      #       )
      #     )
      #   end

      #   def init_week_view(track_day)
      #     state.current_view = "week"
      #     set_state current_controll_component: ->{Native(t(Week, {ref: "week", index: self, date: state.date}))}
      #   end

      #   def init_month_view
      #     state.current_view = "month"
      #     set_state current_controll_component: ->{Native(t(Month, {ref: "month", index: self, date: state.date}))}
      #   end

      #   def init_day_view
      #     state.current_view = "day"
      #     set_state current_controll_component: ->{Native(t(WeekDay, {ref: "day", date: state.date, index: self}))}, current_view: "day"
      #   end

      #   def init_appointments_new(date)
      #     modal_open(
      #       "create appointment",
      #       t(Components::Appointments::Doctors::New, {date: date, on_appointment_created: ->(appo){self.on_appointment_created(appo)}})
      #     )
      #   end

      #   def init_appointments_show(appointment)
      #     modal_open(
      #       "appointment",
      #       t(Components::Appointments::Doctors::Show, {appointment: appointment})
      #     )
      #   end

      #   def init_appointments_edit(appointment)
      #     modal_open(
      #       "edit",
      #       t(Components::Appointments::Doctors::Edit, {id: appointment.id, passed_appointment: appointment, 
      #                                                   on_appointment_updated: ->(a){on_appointment_updated(a)}})
      #     )
      #   end

      #   def current_view
      #     self.ref(state.current_view).rb
      #   end

      #   def delete_appointment(appointment)
      #     appointment.destroy(namespace: 'doctor').then do |_appointment|
      #       current_view.state.appointments.remove(appointment)
      #       current_view.set_state appointments: current_view.state.appointments
      #       current_view.prepare_availability if state.current_view == "day" 
      #     end
      #   end

      #   def on_appointment_updated(appointment)
      #     current_view.set_state appointments: current_view.state.appointments
      #     current_view.prepare_availability if state.current_view == "day" 
      #   end

      #   def on_appointment_created(appo)
      #     current_view.state.appointments << appo
      #     current_view.set_state appointments: current_view.state.appointments
      #     current_view.prepare_availability if state.current_view == "day" 
      #     modal_close
      #   end

      # end

      # class  Month < RW
      #   expose

      #   def prepare_dates
      #     @cur_month = props.date.clone().startOf("month")
      #     @first_wday = @cur_month.day()
      #     @track_day = @cur_month.clone().subtract((@first_wday + 1), "days")
      #   end

      #   def queries(date)
      #     date = @date.clone()
      #     date.startOf("month")
      #     wd = date.day() + 1
      #     x = {}
      #     z = date.subtract((wd), "days")
      #     x[:to] = z.clone().add(weeks: 6, days: 1).format('YYYY-MM-DD')
      #     x[:from] = z.format('YYYY-MM-DD')
      #     x
      #   end

      #   def get_initial_state
      #     @date = props.date
      #     {
      #       appointments: ModelCollection.new
      #     }
      #   end
  
      #   def component_did_mount
      #     Appointment.index(component: self, namespace: "doctor", payload: {from: queries(props.date)[:from], to: queries(props.date)[:to], doctor_ids: [CurrentUser.user_instance.id]}).then do |appointments|
      #       set_state appointments: appointments
      #     end
      #   end
        
      #   def render
      #     prepare_dates     
      #     t(:div, {},
      #       spinner,
      #       t(:button, {onClick: ->{prev_month}}, "<"),
      #       t(:button, {onClick: ->{next_month}}, ">"),
      #       t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"}.to_n },
      #         t(:div, {className: "row", style: {display: "table-row"}.to_n },
      #           *splat_each(Calendar.wdays) do |wday_name| 
      #               t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n }, wday_name)
      #           end,
      #         ),
      #         *splat_each(0..5) do |week_num|
      #           t_d = (@track_day).clone
      #           t(:div, {className: "row", style: {display: "table-row"}.to_n },
      #             t(:div, {},
      #               *splat_each(0..6) do |d|
      #                 t_d_a = (@track_day.add(1, 'days')).clone()
      #                 t(:div, {className: "col-lg-1", style: {"height" => "12em", display: "table-cell", width: "12%", overflow: "scroll"}.to_n }, 
      #                   t(:div, {},
      #                     t(:span, {}, @track_day.date())#,
      #                     #t(:button, {onClick: ->{props.index.init_appointments_new(t_d_a)}}, "add appointment")
      #                   ),
      #                   t(:div, {},
      #                     *splat_each(fetch_appointments(@track_day.format("YYYY-MM-DD"))) do |appointment|
      #                       t(:span, {},
      #                         "#{Moment.new(appointment.start_date).format("HH:mm")} - 
      #                           #{Moment.new(appointment.end_date).format("HH:mm")}",
      #                         t(:button, {onClick: ->{props.index.init_appointments_show(appointment)}}, "show this"),
      #                         t(:button, {onClick: ->{props.index.init_appointments_edit(appointment)}}, "edit this"),
      #                         t(:button, {onClick: ->{props.index.delete_appointment(appointment)}}, "delete this"),
      #                         t(:br, {}),
      #                         "#{appointment.patient.profile.name}",
      #                         t(:br, {}),
      #                         "------------",
      #                         t(:br, {})

      #                       )
      #                     end
      #                   )             
      #                 )
      #               end
      #             )
      #           )
      #         end   
      #       )
      #     )
      #   end

      #   def fetch_appointments(t_d)
      #     state.appointments.where do |a|
      #       next if a == nil
      #       a.attributes[:start_date].include? "#{t_d}"
      #     end
      #   end

      #   def handle(track_day)
      #     props.on_init_week_view(track_day)
      #   end

      #   def prev_month 
      #     props.index.set_state date: (@date = props.index.state.date.subtract(1, "month"))
      #     component_did_mount
      #   end

      #   def next_month
      #     props.index.set_state date: (@date = props.index.state.date.add(1, "month"))
      #     component_did_mount
      #   end
      # end

      # class Week < RW
      #   expose

      #   def queries(date)
      #     x = {}
      #     date = props.date.clone().startOf("week")
      #     x[:from] = date.format('YYYY-MM-DD')
      #     x[:to] = date.add(8, 'days').format('YYYY-MM-DD')
      #     x
      #   end

      #   def get_initial_state
      #     {
      #       appointments: ModelCollection.new
      #     }
      #   end

      #   def component_did_mount
      #     Appointment.index(component: self, namespace: "doctor", payload: {from: queries(props.date)[:from], to: queries(props.date)[:to], doctor_ids: [CurrentUser.user_instance.id]}).then do |appointments|
      #       set_state appointments: appointments
      #     end
      #   end

      #   def fetch_appointments(t_d)
      #     state.appointments.where do |a|
      #       next if a == nil
      #       a.attributes[:start_date].include? "#{t_d}"
      #     end
      #   end

      #   def render
      #     t_d = @track_day = props.date.clone().subtract(1, 'days')
      #     t(:div, {},
      #       spinner,
      #       t(:button, {onClick: ->{prev_week}}, "<"),
      #       t(:button, {onClick: ->{next_week}}, ">"),
      #       t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"}.to_n },
      #         t(:div, {className: "row", style: {display: "table-row"}.to_n },
      #           *splat_each(Calendar.wdays) do |wday_name| 
      #               t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n }, wday_name)
      #           end,
      #         ),
      #         t(:div, {className: "row", style: {display: "table-row"}.to_n },
      #           t(:div, {},
      #             *splat_each(0..6) do |d|
      #               t_d_a = (@track_day.add(1, 'days')).clone()
      #               t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n }, 
      #                 t(:div, {},
      #                   t(:span, {}, @track_day.date())#,
      #                   #t(:button, {onClick: ->{props.index.init_appointments_new(t_d_a)}}, "add appointment")
      #                 ),
      #                 t(:div, {},
      #                   *splat_each(fetch_appointments(@track_day.format("YYYY-MM-DD"))) do |appointment|
      #                     t(:span, {},
      #                       "#{Moment.new(appointment.start_date).format("HH:mm")} - 
      #                         #{Moment.new(appointment.end_date).format("HH:mm")}",
      #                       t(:button, {onClick: ->{props.index.init_appointments_show(appointment)}}, "show this"),
      #                       t(:button, {onClick: ->{props.index.init_appointments_edit(appointment)}}, "edit this"),
      #                       t(:button, {onClick: ->{props.index.delete_appointment(appointment)}}, "delete this"),
      #                       t(:br, {}),
      #                       "#{appointment.patient.profile.name}",
      #                       t(:br, {}),
      #                       "------------",
      #                       t(:br, {})

      #                     )
      #                   end
      #                 )             
      #               )
      #             end
      #           )
      #         ) 
      #       )
      #     )
      #   end

      #   def prev_week 
      #     props.index.set_state date: (props.index.state.date.subtract(7, 'days')) 
      #     component_did_mount
      #   end

      #   def next_week
      #     props.index.set_state date: (props.index.state.date.add(7, 'days'))
      #     component_did_mount
      #   end
        
      # end

      # class WeekDay < RW
      #   expose
      #   #date: the moment the state is on

      #   def get_initial_state
      #     {
      #       appointments: ModelCollection.new,
      #       available: []
      #     }
      #   end

      #   def component_did_mount
      #     Appointment.index(component: self, namespace: "doctor", payload: {from: "#{props.date.format('YYYY-MM-DD')}", to: "#{props.date.clone().add(1, 'days').format('YYYY-MM-DD')}", doctor_ids: [CurrentUser.user_instance.id]}).then do |appointments|
      #       set_state appointments: appointments
      #       begin
      #       prepare_availability
      #     rescue Exception => e
      #       p e
      #     end
      #     end
      #   end

      #   def render
      #     t(:div, {className: "row"},
      #       spinner,
      #       t(:div, {className: "col-lg-6"},
      #         t(:button, {onClick: ->{prev_day}}, "<"),
      #         t(:button, {onClick: ->{next_day}}, ">"),
      #         t(:p, {}, "Today is #{props.date.format('YYYY-MM-DD HH:mm')}"),
      #         *splat_each(state.appointments) do |appointment|
      #           t(:span, {},
      #             "#{Moment.new(appointment.start_date).format("HH:mm")} - 
      #               #{Moment.new(appointment.end_date).format("HH:mm")}",
      #             t(:button, {onClick: ->{props.index.init_appointments_show(appointment)}}, "show this"),
      #             t(:button, {onClick: ->{props.index.init_appointments_edit(appointment)}}, "edit this"),
      #             t(:button, {onClick: ->{props.index.delete_appointment(appointment)}}, "delete this"),
      #             t(:br, {}),
      #             "#{appointment.patient.profile.name}",
      #             t(:br, {}),
      #             "------------",
      #             t(:br, {})
      #           )
      #         end
      #       ),
      #       t(:div, {className: 'col-lg-6'},
      #         t(:p, {}, "here ll be appointment planning for day"),
      #         *splat_each(state.available) do |av|
      #           t(:p, {}, "#{av[:start].format("HH:mm")} - #{av[:end].format("HH:mm")}")
      #         end
      #       )
      #     )
      #   end

      #   def prepare_availability

      #     state.appointments.sort! do |x, y|
      #       x.end_date <=> y.start_date
      #     end

      #     available = []

      #     data = state.appointments.data

      #     if data.length > 0
      #       x = props.date.clone().set(hour: 9, minute: 0)
      #       y = Moment.new(data[0].start_date)
      #       d = y.diff(x, 'minutes')
      #       p "init dif : #{d}"
      #       if d > 20
      #         available << {start: x, end: y}
      #       end

      #       0..data.length.times do |i|
      #         y = Moment.new(data[i].end_date)          
      #         if (i + 1 == data.length)
      #           x = y.clone().set(hour: 19, minute: 0)
      #         else 
      #           x = Moment.new(data[i + 1].start_date)
      #         end
      #         d = x.diff(y, 'minutes')
      #         if d >= 30
      #           available << {start: y, end: x}
      #         end
      #       end
      #     else
      #       available << {start: props.date.clone().set(hour: 9, minute: 0), end: props.date.clone().set(hour: 19, minute: 0)}
      #     end


      #     set_state available: available
      #   end

      #   def prev_day
      #     props.index.set_state date: (props.index.state.date.subtract(1, 'day'))
      #     component_did_mount
      #   end

      #   def next_day
      #     props.index.set_state date: (props.index.state.date.add(1, 'day'))
      #     component_did_mount
      #   end

      # end
    end
  end
end

