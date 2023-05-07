module TimeRegsHelper
  def convert_time(time_reg)
    time_minutes = time_reg.minutes
    return nil if time_minutes.nil?
    hours = time_minutes / 60
    minutes = time_minutes % 60

    if minutes > 10
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
