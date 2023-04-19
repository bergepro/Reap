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
end
