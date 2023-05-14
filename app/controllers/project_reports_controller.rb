class ProjectReportsController < ReportsController

  GROUPES = {"Task" => "task", "Date" => "date", "User" => "user"} # columns to group report by
  START_GROUP = "date" # standard grouping when creating new report

  # show report
  def show

  end

  def new
    @report = ProjectReport.new
    @show_custom_timeframe = false
    @timeframeOptions = get_timeframe_options
    @clients = Client.all
    @projects = []
  end

  def create
    params.inspect
    redirect_to new_project_report_path
  end

  def update_projects_selection
    puts "dssdiokdsidsijsdi--------------------------"
    projects = Project.where(client_id: params[:client_id])
    puts projects.count
    render partial: 'projects', locals: {projects: projects}
  end
end
