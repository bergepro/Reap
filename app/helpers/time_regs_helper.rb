module TimeRegsHelper
  def minutes_by_day_of_week(date, user)
    start_of_week = date.beginning_of_week
    end_of_week = date.end_of_week

    time_regs = user.time_regs.where(date_worked: start_of_week..end_of_week)

    minutes_by_day = Hash.new(0)
    time_regs.each do |time_reg|
      day_of_week = time_reg.date_worked.strftime('%A')
      minutes_by_day[day_of_week] += time_reg.minutes
    end

    minutes_by_day
  end
  
  def convert_time(time_reg)
    time_minutes = time_reg.minutes
    return nil if time_minutes.nil?
    hours = time_minutes / 60
    minutes = time_minutes % 60

    if minutes > 9
      return "#{hours}:#{minutes}"
    else 
      return "#{hours}:0#{minutes}"
    end
  end

  def convert_time_int(minutes)
    return nil if minutes.nil?
    hours = minutes / 60
    minutes = minutes % 60

    if minutes > 9
      return "#{hours}:#{minutes}"
    else 
      return "#{hours}:0#{minutes}"
    end
  end
end
