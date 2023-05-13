class ReportsController < ApplicationController
  # sets the timeframe for the report if it is custom or allTime
  def set_dates(report, timeframe, date_start_params, date_end_params)
    report.timeframe = timeframe
    if timeframe == "custom"
      # handles parse-error
      if !params[:date_start].blank? && !params[:date_end].blank?
        report.date_start = Date.parse(date_start_params)
        report.date_end = Date.parse(date_end_params)
      end
    elsif timeframe == "allTime"
      report.date_start = nil
      report.date_end = nil
    elsif timeframe == nil
      report.timeframe = nil
    else
      puts "set dates normal timefram"
      report = set_timeframe(report)
    end
    report
  end

  # sets the reports timeframe if it is not allTime or custom
  def set_timeframe(report)
    timeframe = report.timeframe
    today = Date.today

    new_date_start = nil
    new_date_end = nil

    if timeframe == "thisWeek"
      new_date_start = today.beginning_of_week
      new_date_end = today
    elsif timeframe == "lastWeek"
      new_date_start = today.last_week.beginning_of_week
      new_date_end = today.last_week.end_of_week
    elsif timeframe == "thisMonth"
      new_date_start = today.beginning_of_month
      new_date_end = today
    elsif timeframe == "lastMonth"
      new_date_start = today.last_month.beginning_of_month
      new_date_end = today.last_month.end_of_month
    end
    report.date_start = new_date_start
    report.date_end = new_date_end

    report
  end

  # creates a hash for the different timeframe options
  def get_timeframe_options 
    thisMonthName = I18n.t("date.month_names")[Date.today.month]
    lastMonthName = I18n.t("date.month_names")[Date.today.month-1]
    timeFrameOptions = { 
                          "Custom" => 'custom', 
                          "This week" => 'thisWeek',
                          "Last week" => 'lastWeek',
                          "This Month (#{thisMonthName})" => 'thisMonth',
                          "Last month (#{lastMonthName})" => 'lastMonth',
                          "All Time" => 'allTime'
                        }
  end
end
