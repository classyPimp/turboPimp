require "date"

class Calendar < RW
  expose

  def self.wdays
    ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
  end

  def initial_state
    {
      date: Date.today
    }
  end

  def render
    t(:div, {}, 
      t(:button, {onClick: ->(){prev_month}}, "<"),
      t(:button, {onClick: ->(){next_month}}, ">"),
      t(:p, {}, "the month is #{state.date.month}, of year #{state.date.year}"),
      t(Month, {date: state.date, on_show_week: ->(week_num, cur_month){show_week(week_num, cur_month)}}),
      t(:br, {}),
      t(:div, {},
        if state.week
          t(Week, state.week_options)
        end
      )
    )
  end

  def show_week(week_num, cur_month)
    state.week_options = {week_num: week_num, cur_month: cur_month}
    set_state week: true
  end

  def prev_month 
    set_state date: state.date.prev_month
  end

  def next_month
    set_state date: state.date.next_month
  end

end

class  Month < RW
  expose
  
  def render
    @cur_month = props.date - (props.date.day - 1)
    @days_in_month = @cur_month.next_month.prev_day.day
    @first_wday = @cur_month.wday
    @m_d_counter = 1
    @prev_month = @cur_month.prev_day.day
    @next_month = @cur_month.next_month.day


    t(:div, {},
      t(:table, {},
        t(:tbody, {},
          t(:tr, {},
            *splat_each(Calendar.wdays) do |wday_name| 
                t(:th, {}, wday_name)
            end
          ),
          *splat_each(0..4) do |week_num|
            @first_iter = (week_num == 0 && @first_wday != 0) ? true : false
            t(:tr, {onClick: ->(){handle(week_num , @cur_month)}},
              *splat_each(0..6) do |wday_num|
                if @first_iter
                    to_return = t(:td, {}, (@prev_month - @first_wday + 1))
                    @first_wday -= 1
                    if @first_wday == 0
                      @first_iter = false
                    end
                    to_return
                else
                  to_ret = t(:td, {}, (@days_in_month >= @m_d_counter) ? @m_d_counter : (@next_month += 1; (@next_month - 1)))
                  @m_d_counter += 1
                  to_ret
                end
              end
            )
          end
        )     
      )
    )
  
  end

  def handle(week_num, cur_month)
    props.on_show_week(week_num, cur_month)
  end
end

class Week < RW
  expose
  def days_in_month

  end

  def calculate_start_day
    x = 1 + (7 - @first_wday)
    if props.week_num > 1
      x + 7 * (props.week_num - 1)
    elsif props.week_num == 1
      x
    else
      1
    end
  end

  def render
    @cur_month = props.cur_month
    @days_in_month = @cur_month.next_month.prev_day.day
    @first_wday = @cur_month.wday
    @prev_month = @cur_month.prev_day.day
    @next_month = @cur_month.next_month.day
    @m_d_counter = calculate_start_day

    t(:div, {},
      t(:table, {},
        t(:tbody, {},
          t(:tr, {},
            *splat_each(Calendar.wdays) do |wday_name| 
                t(:th, {}, wday_name)
            end
          ),
          t(:tr, {},
            *splat_each(0..6) do |wday_num|
              if props.week_num == 0
                if @first_wday > 0
                  @first_wday -= 1
                  t(:td, {}, (@prev_month - @first_wday))
                else
                  @m_d_counter += 1
                  to_ret = t(:td, {}, (@days_in_month >= (@m_d_counter - 1)) ? (@m_d_counter - 1) : (@next_month += 1; (@next_month - 1)))
                end
              else
                @m_d_counter += 1
                to_ret = t(:td, {}, (@days_in_month >= (@m_d_counter - 1)) ? (@m_d_counter - 1) : (@next_month += 1; (@next_month - 1)))
              end
            end
          )
        )     
      )
    )
  end
  
end
