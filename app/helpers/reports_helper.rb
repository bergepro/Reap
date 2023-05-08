module ReportsHelper
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
