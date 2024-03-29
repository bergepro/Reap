module ReportsHelper
  # converts time-regs minutes to "0:00" format
  def convert_time_int(minutes)
    return nil if minutes.nil?

    hours = minutes / 60
    minutes = minutes % 60

    return "#{hours}:#{minutes}" if minutes > 9

    "#{hours}:0#{minutes}"
  end
end
