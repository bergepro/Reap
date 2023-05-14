class ProjectReportsController < ReportsController

  GROUPES = {"Task" => "task", "Date" => "date", "User" => "user"} # columns to group report by
  START_GROUP = "date" # standard grouping when creating new report

  # show report
  def show

  end

  def new
    @report = ProjectReport.new
    @timeframeOptions = get_timeframe_options
    @clients = Client.all
  end

  def create
    params.inspect
    redirect_to new_project_report_path
  end
end
