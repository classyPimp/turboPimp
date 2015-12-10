require "date"
class Eventy < Model
    attributes :start, :finish, :position, :all_day
    attr_accessor :_start, :_finish

    def init
       @_start = `new Date(#{self.start})`
       @_finish ? (@_finish = `new Date(#{self.finsih})`) : @_start
    end

    def self.prepare(ar)
      res = {}
      ar.each do |ev|
        (res["#{ev.start}"] ||= []) << ev
      end
      res
    end

    def dif_days
      %x{
      oneDay = 86400000
      var firstDate = #{@_finish}
      var secondDate = #{@_start}
      var diffDays = Math.round(Math.abs((firstDate.getTime() - secondDate.getTime())/(oneDay)))
      return diffDays
      }
    end
end


class Calendar < RW
  expose

  def self.wdays
    ["sun", "mon", "tue", "wed", "thur", "fri", "sat" ]
  end

  def init 
    
  end

  def get_initial_state
    {
      date: Date.today
    }
  end

  def render
    t(:div, {},
      t(:p, {}, "click on week"), 
      t(:button, {onClick: ->(){prev_month}}, "<"),
      t(:button, {onClick: ->(){next_month}}, ">"),
      t(:p, {}, "the month is #{state.date.month}, of year #{state.date.year}"),
      t(Month, {date: state.date, on_show_week: ->(track_day){show_week(track_day)}}),
      t(:br, {}),
      t(:div, {},
        if state.week
          t(Week, state.week_options)
        end
      )
    )
  end

  def show_week(track_day)
    state.week_options = {track_day: track_day}
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
  
  def get_initial_state
    {
      events_feed: Model.parse([
                                {eventy: {start: "2015-11-21", finish: "2015-11-21"}},
                                {eventy: {start: "2015-11-21", finish: "2015-11-23"}},
                                {eventy: {start: "2015-11-24", finish: "2015-11-24"}},
                                {eventy: {start: "2015-11-22", finish: "2015-11-22"}},
                                {eventy: {start: "2015-11-23", finish: "2015-11-27"}},
                                {eventy: {start: "2015-11-25", finish: "2015-11-26"}},
                                {eventy: {start: "2015-11-28", finish: "2015-11-28"}}
                              ])
    }
  end


  def render
    @ev_feed = Eventy.prepare(state.events_feed)
    @cur_month = props.date - (props.date.day - 1)
    @first_wday = @cur_month.wday
    @track_day = @cur_month.clone - (@first_wday + 1)

    t(:div, {},
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
            t(:div, {onClick: ->(){handle(t_d)}},
              *splat_each(0..6) do |d|
                t(:div, {className: "col-lg-1", style: {"height" => "20%"}}, 
                  t(:p, {}, (@track_day += 1).day),
                  *splat_each(0..6) do |x|
                    z = "#{@track_day.year}-#{@track_day.month}-#{@track_day.day}"
                    val = @ev_feed[z].pop if @ev_feed[z]
                    t(:p, {}, val ? "#{val.start} - #{val.finish}" : "")
                  end
                )
              end
            ),
            t(:div, {className: "col-lg-3"})
=begin
            *splat_each(0..6) do |d|
              t(:tr, {},
                *(
                span_track = 0
                x = splat_each(0..6) do |x|
                  t_d += 1
                  z = "#{t_d.year}-#{t_d.month}-#{t_d.day}"
                  val = @ev_feed[z].pop if @ev_feed[z]
                  t(:td, {}, val ? "#{val.start} - #{val.finish}" : "nil")
                end
                t_d -= 7
                x
                )
              )
            end
=end
          )
        end   
      )
    )
  end

  def handle(track_day)
    props.on_show_week(track_day)
  end
end

class Week < RW
  expose

  def render
    @track_day = props.track_day.clone

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
              t(:td, {}, (@track_day += 1).day)
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
