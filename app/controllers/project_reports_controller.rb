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
    @tasks = []
  end

  def create
    @report = ProjectReport.new(project_report_params)
    set_dates(@report) unless @report.timeframe == "custom"
    @report.group_by = START_GROUP

    if @report.save
      redirect_to @report
    else
      @show_custom_timeframe = @report.timeframe == "custom" ? true : false
      @timeframeOptions = get_timeframe_options
      @clients = Client.all
      @projects = @report.client_id.present? ? Project.where(client_id: @report.client_id) : []
      if @report.project_id.present?
        @members = @report.member_ids.present? ? Project.find(@report.project_id).users : []
        @tasks = @report.task_ids.present? ? Project.find(@report.project_id).tasks : []   
      else 
        @members = []
        @tasks = []
      end
      render :new, status: :unprocessable_entity 
    end
    
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

  private 
  def project_report_params
    params.require(:project_report).permit(:timeframe, :date_start, :date_end, :client_id, :project_id, member_ids: [], task_ids: [])
  end
end
