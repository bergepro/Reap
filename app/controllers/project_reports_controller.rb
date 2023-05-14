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
    @members = []
    @tasks
  end

  def create
    params.inspect
    redirect_to new_project_report_path
  end

  def update_projects_selection
    projects = Project.where(client_id: params[:client_id])
    render partial: 'projects', locals: {projects: projects}
  end

  def update_members_checkboxes
    members = Project.find(params[:project_id]).users
    render partial: 'checkboxes', locals: {report: ProjectReport.new, checkboxes: members, text: 'member',}
  end

  def update_tasks_checkboxes
    tasks = Project.find(params[:project_id]).tasks
    render partial: 'checkboxes', locals: {report: ProjectReport.new, checkboxes: tasks, text: 'task',}
  end
end
