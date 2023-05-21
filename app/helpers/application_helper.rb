module ApplicationHelper
  def format_duration(total_minutes)
    hours = total_minutes / 60
    minutes = total_minutes % 60
    seconds = (total_minutes * 60) % 60
    format('%02d:%02d:%02d', hours, minutes, seconds)
  end
end
