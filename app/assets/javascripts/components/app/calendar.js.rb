require "date"
class Event
    attr_accessor :start, :finish
    
    def initialize(x,y = x)
       @start = `new Date(x)`
       @finish = `new Date(y)`
    end

    def self.prepare(ar)
      res_h = {}
      ar.sort_by do |a|
          x = a.dif_days
          (0..x).each do |i|
            foo = `new Date(#{a.start})`
            `
              var tomorrow = new Date()
              #{foo}.setDate(#{foo}.getDate() + i)
            `
            z = "#{`#{`foo`}.getFullYear()`}-#{`#{`foo`}.getMonth() + 1`}-#{`#{`foo`}.getDate()`}"
            p z
         end
      end

    end

    def dif_days
      %x{
      oneDay = 86400000
      var firstDate = #{self.finish}
      var secondDate = #{self.start}
      var diffDays = Math.round(Math.abs((firstDate.getTime() - secondDate.getTime())/(oneDay)))
      return diffDays
      }
    end

end

Document.ready? do
  x = [Event.new("2015-10-25", "2015-12-25")]
  Event.prepare(x)
end
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
    @prev_month = @cur_month.prev_day
    @next_month = @cur_month.next_month


    t(:div, {},
      t(:table, {},
        t(:thead, {},
          t(:tr, {},
            *splat_each(Calendar.wdays) do |wday_name| 
                t(:th, {}, wday_name)
            end
          )
        ),
        t(:tbody, {},
          *splat_each(0..4) do |week_num|
            @first_iter = (week_num == 0 && @first_wday != 0) ? true : false
            t(:tr, {onClick: ->(){handle(week_num , @cur_month)}},
              *splat_each(0..6) do |wday_num|
                if @first_iter
                    to_return = t(:td, {ref: "#{@prev_month.year}-#{@prev_month.month}-#{@prev_month.day - @first_wday + 1}"}, (@prev_month.day - @first_wday + 1))
                    @first_wday -= 1
                    if @first_wday == 0
                      @first_iter = false
                    end
                    to_return
                else
                  if (@days_in_month >= @m_d_counter) 
                    day_num = @m_d_counter
                    month_to_pass = @cur_month 
                  else
                    month_to_pass = @next_month
                    day_num = @next_month.day 
                    @next_month += 1
                  end
                  @m_d_counter += 1
                  t(:td, {ref: "#{month_to_pass.year}-#{month_to_pass.month}-#{day_num}"}, day_num)
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
    @prev_month = @cur_month.prev_day
    @next_month = @cur_month.next_month
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
                  day_num = @prev_month.day - @first_wday
                  t(:td, {className: "#{@prev_month.year}-#{@prev_month.month}-#{day_num}"}, day_num)
                else
                  to_ret = t(:td, {className: "#{@cur_month.year}-#{@cur_month.month}-#{@m_d_counter}"}, @m_d_counter)
                  @m_d_counter += 1
                  to_ret
                end
              else
                if (@days_in_month >= @m_d_counter) 
                  day_num = @m_d_counter
                  month_to_pass = @cur_month 
                else
                  month_to_pass = @next_month
                  day_num = @next_month.day 
                  @next_month += 1
                end
                @m_d_counter += 1
                t(:td, {className: "#{month_to_pass.year}-#{month_to_pass.month}-#{day_num}"}, day_num)
              end
            end
          )
        )     
      )
    )
  end
  
end

class WeekDay < RW
  expose

  def method_name
    
  end

end
