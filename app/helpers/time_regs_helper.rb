module TimeRegsHelper
  def convert_time(time_reg)
    time_minutes = time_reg.minutes
    hours = time_minutes / 60
    minutes = time_minutes % 60
    "#{hours}:#{minutes}"
  end
end
