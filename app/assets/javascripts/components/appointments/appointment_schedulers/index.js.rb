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
          doctor_ids = props.uniq_profiles.keys if props.uniq_profiles
          date = Moment.new(props.date).startOf('day')
          preselected_doctors = props.uniq_profiles ?  {doctors: props.uniq_profiles.values} : {} 
          {
            date: date,
            current_controll_component: Native(:div, {}).to_n,
            current_view: "day",
            doctor_ids: doctor_ids,
            doctor_ids_holder: Model.new(preselected_doctors)
          }
        end

        def component_did_mount
          init_day_view
        end

        def render
          t(:div, {className: 'appointments_calendar'},
            modal,
            t(:h2, {className: 'view_title_date'}, "#{state.date.month() + 1}.#{state.date.year()}"),
            t(:div, {className: 'view_controlls col-lg-6'},
              #t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_month_view}}, "month"),
              t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_week_view(state.date.clone())}}, "week"),
              t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{init_day_view(state.date.clone())}}, "day"),
              t(:button, {className: 'btn btn-primary btn-xs', onClick: ->{set_state date: Moment.new}}, "go to today"),
              t(:br, {}),
              input(Forms::Select, state.doctor_ids_holder, :doctors, {multiple: true, s_value: 'name',  
                option_as_model: true, server_feed: {url: "/api/doctor/users/doctors_feed"}, namespace: 'doctors_select'}, destroy: false),
              t(:button, { onClick: ->{refine_doctor_ids} }, 'update with chosen doctors')            
            ),
            if props.from_proposal
              t(:div, {className: 'col-lg-6'},
                t(Components::Appointments::AppointmentSchedulers::Partials::DesiredAppointments, {appointment_proposal_infos: props.appointment.appointment_proposal_infos})
              )
            end, 
            t(:div, {},
              state.current_controll_component.to_n
            )
          )
        end

        def init_appointments_new(date)
          date = date.clone
          modal_open(
            "create appointment",
            t(Components::Appointments::Doctors::New, {date: date, on_appointment_created: ->(appo){self.on_appointment_created}})
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
            'edit appointment',
            t(Components::Appointments::Doctors::Edit, {id: appointment.id, on_appointment_updated: event(->{on_appointment_updated})})
          )
        end

        def destroy_appointment(appointment)
          appointment.destroy(namespace: 'doctor').then do |appointment|
            ref(state.current_view).rb.component_did_mount
          end
        end

        def on_appointment_updated
          modal_close
          create_flash('updated')
          ref(state.current_view).rb.component_did_mount
        end

        def on_appointment_created
          if props.from_proposal
            emit(:on_appointment_created)
          else
            ref(state.current_view).rb.component_did_mount
            create_flash('appointment successfully created')
          end
          modal_close          
        end

        def init_appointments_appointment_schedulers_new_from_proposal(date)
          modal_open(
            'schedule',
            t(Components::Appointments::AppointmentSchedulers::NewFromProposal, {date: date.clone, appointment: props.appointment, on_appointment_created: event(->{on_appointment_created})} )
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

        def events_to_attach
          to_attach = {}
          if props.from_proposal
            to_attach[:init_appointments_new_from_proposal] = event(->(date){init_appointments_appointment_schedulers_new_from_proposal(date)})
          else
            to_attach[:init_appointments_new] = event(->(date){init_appointments_new(date)})
          end
          to_attach
        end

        def init_patient_show(patient)
          modal_open(
            'patient',
            t(Components::Users::Show, {user_id: patient.id})
          )
        end

        def init_week_view(track_day)
          state.current_view = "week"
          set_state current_controll_component: ->{Native(t(Week, {ref: "week", index: self, date: state.date}.merge(events_to_attach)))}
        end       

      #   def init_month_view
      #     state.current_view = "month"
      #     set_state current_controll_component: ->{Native(t(Month, {ref: "month", index: self, date: state.date}.merge(events_to_attach)))}
      #   end

        def init_day_view(date = false)
          state.current_view = "day"
          if date
            state.date = date
          end
          set_state current_controll_component: ->{Native(t(WeekDay, {ref: "day", date: state.date, index: self}.merge(events_to_attach)))}, current_view: "day"
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
            if k[0] == "_"
              h[k] = Hash.new(&tree_block)
            else
              h[k] = {doctor: nil, appointments: []}
            end
          }
          opts = Hash.new(&tree_block)
          users.each do |user|
            #opts[Moment.new(appointment.start_date).format('_YYYY-MM-DD')][user.profile.name][:doctor] = user
            user.appointments.each do |appointment|
              opts[Moment.new(appointment.start_date).format('_YYYY-MM-DD')][user.id][:appointments] << appointment
              opts[Moment.new(appointment.start_date).format('_YYYY-MM-DD')][user.id][:doctor] = user
            end
          end
          obj.set_state appointments_for_dates: opts
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
                *splat_each(Services::Calendar.wdays) do |wday_name| 
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
      #           *splat_each(Services::Calendar.wdays) do |wday_name| 
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
        #resolves dates that'll be used for querrying the apppointments
        def queries(date)

          z = date.clone().startOf("week")
          #z = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : z 
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

        #fetches appointments
        # if something else except fetching is added move to other method beacause on update it calls #component_did_mount
        def component_did_mount
          Appointment.index(component: self, payload: queries(props.date).merge(doctor_ids: props.index.state.doctor_ids), namespace: 'appointment_scheduler').then do |users|
            begin
            props.index.prepare_appointments_tree(self, users) 
            rescue Exception => e
              p e
            end
          end
        end

        #if date is different fetches for new date
        def component_did_update(prev_props, prev_state)
          if props.date.format != prev_props.date.format
            component_did_mount
          end     
        end

        def render
          #TODO: move to flexbox
          passed_day = ''
          current_day = Moment.new
          t_d = @track_day = props.date.clone().startOf('week').subtract(1, 'days')
          t(:div, {},
            spinner,
            t(:div, {className: 'row'}, 
              t(:div, {className: 'prev_next_controlls'}, 
                t(:button, {onClick: ->{prev_week}}, "<"),
                t(:button, {onClick: ->{next_week}}, ">"),
              ),
              t(:div, {className: "col-lg-1 week_day_panel #{$VIEW_PORT_KIND}"},
                  t(MonthBox, {date: props.date, index: props.index})
              )
            ),
            t(:div, {className: 'row'},
              modal, 
              
              *splat_each(0..6) do |d|

                t_d_a = (@track_day.add(1, 'days')).clone()

                t(:div, {className: "col-lg-1 week_day_panel #{$VIEW_PORT_KIND}"},
                  t(:div, {className: "day_heading #{passed_day}", onClick: ->{props.index.init_day_view(t_d_a)}}, 
                    t(:h4, {className: 'wday_name'}, 
                      Services::Calendar.wdays[d]
                    ),
                    t(:p, {}, @track_day.date())
                  ),
                  if props.index.props.from_proposal
                    t(:button, {className: 'btn btn-primary btn-xs' ,onClick: ->{ emit(:init_appointments_new_from_proposal, t_d_a) } }, 'create appointment')
                  else
                    t(:button, { onClick: ->{ emit(:init_appointments_new, t_d_a)} }, 'create new appointment')
                  end,

                    t(:div, {className: "day_body"},
                      *splat_each(props.index.fetch_appointments(self, t_d_a.format("_YYYY-MM-DD"))) do |k, h|
                        t(:div, {className: 'appointments_for_doctor'},
                          link_to('', "/users/show/#{h[:doctor].id}") do
                            t(:p, {className: 'doctor_name'}, 
                              "#{h[:doctor].profile.name}"
                            )
                          end,
                          *splat_each(h[:appointments]) do |appointment|
                            t(:div, {},
                              t(:a, {},
                                t(:p, {className: 'patient_name', onClick: ->{props.index.init_patient_show(appointment.patient)}},
                                  "#{appointment.patient.profile.name}"
                                )
                              ),
                              t(:a, {className: 'appointment_time', onClick: ->{props.index.init_appointments_show(appointment)}}, 
                               "#{Moment.new(appointment.start_date).format("HH:mm")} - #{Moment.new(appointment.end_date).format("HH:mm")}"
                              ),
                              t(:div, {className: 'controlls'},
                                t(:button, {className: 'btn btn-xs', onClick: ->{props.index.init_appointments_edit(appointment)}},
                                  'edit'
                                ),
                                t(:button, {className: 'btn btn-xs', onClick: ->{props.index.destroy_appointment(appointment)}},
                                  'delete'
                                )
                              )
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

        # def init_appointments_proposals_new(date)
        #   modal_open(
        #     "book an appointment",
        #     t(Components::Appointments::Proposals::New, {date: date, appointment_availabilities: props.index.fetch_appointments(self, date.clone.format("YYYY-MM-DD")), user_accessor: state.user_accessor, on_appointment_proposal_created: event(->{modal_close})})
        #   )
        # end

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

        def component_did_update(prev_props, prev_state)
          if props.date.format != prev_props.date.format
            component_did_mount
          end     
        end

        # def component_did_update(prev_props, prev_state)
        #   if props.date.format != prev_props.date.format
        #     component_did_mount
        #   end     
        # end

        def render
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
                  Services::Calendar.wdays[props.date.day()]
                ),
                t(:p, {}, props.date.format('DD'))
              ),
              if props.index.props.from_proposal
                t(:button, { onClick: ->{ emit(:init_appointments_new_from_proposal, props.date) } }, 'create appointment')
              else
                t(:button, { onClick: ->{emit(:init_appointments_new, props.date)} }, 'create new appointment')
              end,
              t(:div, {className: "day_body"},
                *splat_each(props.index.fetch_appointments(self, props.date.clone.format("_YYYY-MM-DD"))) do |k, h|
                  t(:div, {className: 'appointments_for_doctor'},
                    t(:p, {className: 'doctor_name'}, 
                      "#{h[:doctor].profile.name}"
                    ),
                    *splat_each(h[:appointments]) do |appointment|
                      t(:div, {},
                        t(:p, {className: 'patient_name'},
                          "#{appointment.patient.profile.name}"
                        ),
                        t(:p, {className: 'appointment_time'}, 
                         "#{Moment.new(appointment.start_date).format("HH:mm")} - #{Moment.new(appointment.end_date).format("HH:mm")}"
                        )
                      )
                    end
                  )                  
                end     
              )
            ),
            t(:div, {className: 'col-lg-3'})
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

      #   include Plugins::Formable

      #   def self.wdays
      #     ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
      #   end

      #   def get_initial_state
      #     doctor_ids = props.uniq_profiles.keys
      #     date = Moment.new(props.date).startOf('day')
      #     {
      #       date: date,
      #       current_controll_component: Native(:div, {}).to_n,
      #       current_view: "day",
      #       doctor_ids: doctor_ids,
      #       doctor_ids_holder: Model.new(doctors: props.uniq_profiles.values)
      #     }
      #   end

      #   def component_did_mount
      #     init_day_view
      #   end

      #   def render
      #     t(:div, {},
      #       modal,
      #       t(:div, {className: 'row'},
      #         t(:div, {className: 'col-lg-6'},
      #           t(:p, {}, "the month is #{state.date.month() + 1}, of year #{state.date.year()}"),
      #           t(:button, {onClick: ->{init_month_view}}, "month"),
      #           t(:button, {onClick: ->{init_week_view(state.date.clone())}}, "week"),
      #           t(:button, {onClick: ->{init_day_view}}, "day"),
      #           t(:button, {onClick: ->{set_state date: Moment.new}}, "go to today"),
      #           t(:br, {}),
      #           input(Forms::Select, state.doctor_ids_holder, :doctors, {multiple: true, s_value: 'name',  
      #             option_as_model: true, server_feed: {url: "/api/doctor/users/doctors_feed"}, namespace: 'doctors_select'}, destroy: false),
      #           t(:button, { onClick: ->{refine_doctor_ids} }, 'update with choesen doctors')
      #         ),
      #         if props.from_proposal
      #           t(:div, {className: 'col-lg-6'},
      #             t(Components::Appointments::AppointmentSchedulers::Partials::DesiredAppointments, {appointment_proposal_infos: props.appointment.appointment_proposal_infos})
      #           )
      #         end 
      #       ),
      #       t(:div, {},
      #         state.current_controll_component.to_n
      #       )
      #     )
      #   end

      #   def init_appointments_new(date)
      #     date = date.clone
      #     modal_open(
      #       "create appointment",
      #       t(Components::Appointments::Doctors::New, {date: date, on_appointment_created: ->(appo){ref(state.current_view).rb.component_did_mount}})
      #     )
      #   end

      #   def init_appointments_appointment_schedulers_new_from_proposal(date)
      #     modal_open(
      #       'schedule',
      #       t(Components::Appointments::AppointmentSchedulers::NewFromProposal, {date: date.clone, appointment: props.appointment} )
      #     )
      #   end

      #   def refine_doctor_ids
      #     collect_inputs(namespace: 'doctors_select', validate: false)
      #     ids = [] 
      #     state.doctor_ids_holder.attributes[:doctors].each do |profile|
      #       ids << profile.user_id
      #     end
      #     state.doctor_ids = ids
      #     ref(state.current_view).rb.component_did_mount
      #   end

      #   def events_to_attach
      #     to_attach = {}
      #     if props.from_proposal
      #       to_attach[:init_appointments_new_from_proposal] = event(->(date){init_appointments_appointment_schedulers_new_from_proposal(date)})
      #     else
      #       to_attach[:init_appointments_new] = event(->(date){init_appointments_new(date)})
      #     end
      #     to_attach
      #   end

      #   def init_week_view(track_day)
      #     state.current_view = "week"
      #     set_state current_controll_component: ->{Native(t(Week, {ref: "week", index: self, date: state.date}.merge(events_to_attach)))}
      #   end

      #   def init_month_view
      #     state.current_view = "month"
      #     set_state current_controll_component: ->{Native(t(Month, {ref: "month", index: self, date: state.date}.merge(events_to_attach)))}
      #   end

      #   def init_day_view
      #     state.current_view = "day"
      #     set_state current_controll_component: ->{Native(t(WeekDay, {ref: "day", date: state.date, index: self}.merge(events_to_attach)))}, current_view: "day"
      #   end

      #   def current_view
      #     self.ref(state.current_view).rb
      #   end

      #   #method is used and coupled to Week Month WeekDay
      #   #called from there by accessing through props.index, so self should be passed as index prop
      #   def fetch_appointments(obj, t_d)
      #     users = (z = obj.state.appointments_for_dates[t_d]) ? z : {}
      #     users
      #   end

      #   def prepare_appointments_tree(obj, users)
      #     tree_block = lambda{ |h, k| 
      #       if k[0] == "2"
      #         h[k] = Hash.new(&tree_block)
      #       else
      #         h[k] = []
      #       end
      #     }
      #     opts = Hash.new(&tree_block)
      #     users.each do |user|
      #       user.appointments.each do |appointment|
      #         opts[Moment.new(appointment.start_date).format('YYYY-MM-DD')][user.profile.name] << appointment 
      #       end
      #     end
      #     obj.set_state appointments_for_dates: opts
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
      #       appointments_for_dates: {}
      #     }
      #   end

      #   def component_did_mount
      #     Appointment.index(component: self, payload: queries(props.date).merge(doctor_ids: props.index.state.doctor_ids), namespace: 'appointment_scheduler').then do |users|
      #       props.index.prepare_appointments_tree(self, users) 
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
      #           *splat_each(Services::Calendar.wdays) do |wday_name| 
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
      #                   if props.index.props.from_proposal
      #                     t(:button, { onClick: ->{ emit(:init_appointments_new_from_proposal, t_d_a) } }, 'create appointment')
      #                   else
      #                     t(:button, { onClick: ->{emit(:init_appointments_new, t_d_a)} }, 'create new appointment')
      #                   end,
      #                   t(:div, {},
      #                     *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |user_name, appointments|
      #                       t(:div, {},
      #                         t(:p, {}, user_name),
      #                         *splat_each(appointments) do |appointment|
      #                           t(:div, {},
      #                             t(:p, {}, "#{Moment.new(appointment.start_date).format('HH:mm')} : #{Moment.new(appointment.end_date).format('HH:mm')}")
      #                           )
      #                         end
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

      # class Week < RW
      #   expose

      #   def queries(date)
      #     z = date.clone().startOf("week")
      #     z = date.isBefore(x = Moment.new.set(hour: 0, min: 0)) ? x : date 
      #     x = {}
      #     x[:from] = z.format('YYYY-MM-DD')
      #     x[:to] = z.clone().endOf('week').format('YYYY-MM-DD')
      #     x
      #   end

      #   def get_initial_state
      #     {
      #       appointments_for_dates: {}
      #     }
      #   end

      #   def component_did_mount
      #     Appointment.index(component: self, payload: queries(props.date).merge(doctor_ids: props.index.state.doctor_ids), namespace: 'appointment_scheduler').then do |users|
      #       props.index.prepare_appointments_tree(self, users) 
      #     end
      #   end

      #   def render
      #     t_d = @track_day = props.date.clone().startOf('week').subtract(1, 'days')
      #     t(:div, {},
      #       spinner,
      #       t(:button, {onClick: ->{prev_week}}, "<"),
      #       t(:button, {onClick: ->{next_week}}, ">"),
      #       t(:div, {className: "table", style: {display: "table", fontSize:"10px!important"}.to_n },
      #         t(:div, {className: "row", style: {display: "table-row"}.to_n },
      #           *splat_each(Services::Calendar.wdays) do |wday_name| 
      #               t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n }, wday_name)
      #           end,
      #         ),
      #         t(:div, {className: "row", style: {display: "table-row"}.to_n },
      #           t(:div, {},
      #             *splat_each(0..6) do |d|
      #               t_d_a = (@track_day.add(1, 'days')).clone()
      #               t(:div, {className: "col-lg-1", style: {display: "table-cell", width: "12%"}.to_n }, 
      #                 t(:div, {},
      #                   t(:span, {}, @track_day.date()),
      #                 ),
      #                 if props.index.props.from_proposal
      #                   t(:button, { onClick: ->{ emit(:init_appointments_new_from_proposal, t_d_a) } }, 'create appointment')
      #                 else
      #                   t(:button, { onClick: ->{emit(:init_appointments_new, t_d_a)} }, 'create new appointment')
      #                 end,
      #                 t(:div, {},
      #                   *splat_each(props.index.fetch_appointments(self, @track_day.format("YYYY-MM-DD"))) do |user_name, appointments|
      #                     t(:div, {},
      #                       t(:p, {}, user_name),
      #                       *splat_each(appointments) do |appointment|
      #                         t(:div, {},
      #                           t(:p, {}, "#{Moment.new(appointment.start_date).format('HH:mm')} : #{Moment.new(appointment.end_date).format('HH:mm')}")
      #                         )
      #                       end
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
      #       appointments_for_dates: {}
      #     }
      #   end

      #   def component_did_mount
      #     Appointment.index(component: self, payload: {doctor_ids: props.index.state.doctor_ids, from: props.date.clone.startOf('day').format(), to: props.date.clone.endOf('day').format()}, namespace: 'appointment_scheduler').then do |users|
      #       props.index.prepare_appointments_tree(self, users) 
      #     end
      #   end

      #   def render
      #     t(:div, {className: "row"},
      #       spinner,
      #       modal,
      #       t(:div, {className: "col-lg-6"},
      #         t(:button, {onClick: ->{prev_day}}, "<"),
      #         t(:button, {onClick: ->{next_day}}, ">"),
      #         t(:p, {}, "Today is #{props.date.format('YYYY-MM-DD HH:mm')}"),
      #         if props.index.props.from_proposal
      #           t(:button, { onClick: ->{ emit(:init_appointments_new_from_proposal, props.date) } })
      #         else
      #           t(:button, { onClick: ->{emit(:init_appointments_new, props.date)} }, 'create new appointment')
      #         end,
      #         t(:div, {},
      #           *splat_each(props.index.fetch_appointments(self, props.date.clone.format("YYYY-MM-DD"))) do |user_name, appointments|
      #             t(:div, {},
      #               t(:p, {}, user_name),
      #               *splat_each(appointments) do |appointment|
      #                 t(:div, {},
      #                   t(:p, {}, "#{Moment.new(appointment.start_date).format('HH:mm')} : #{Moment.new(appointment.end_date).format('HH:mm')}")
      #                 )
      #               end
      #             )                  
      #           end
      #         )              
      #       )
      #     )
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

