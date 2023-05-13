class UserReportsController < ReportsController
  GROUPES = ["task", "project", "date"] # columns to group report by
  START_GROUP = "date"

  def show
    @report = UserReport.find(params[:id])

  end

  def edit
    @report = UserReport.find(params[:id])
    @TimeFrameOptions = get_timeframe_options
    @users = User.all
    @projects_by_client = User.find(@report.user).projects.group_by(&:client)
    @tasks = @report.project_ids.present? ? Task.joins(:assigned_tasks).where(assigned_tasks: { project_id: @report.project_ids }) : []
    @selected_tasks = @report.task_ids || []
  end
  
  def new
      @selected_tasks = []
      @report = UserReport.new
      @users = User.all
      @projects_by_client = []
      @tasks = []
      @TimeFrameOptions = get_timeframe_options
  end

  def create
    @report = UserReport.new
  
    puts params.inspect
    @report = set_dates(@report, filtered_params[:timeframe], params[:date_start], params[:date_end])
    @report.assign_attributes(filtered_params)      
    @report.project_ids = params[:project_ids] || []
    @report.group_by = START_GROUP
  
    @report.task_ids = params[:task_ids] || []
  
    if @report.save
      redirect_to @report
    else
      @users = User.all
      @projects_by_client = @report.user.present? ? User.find(@report.user).projects.group_by(&:client) : []
  
      @tasks = @report.project_ids.present? ? Task.joins(:assigned_tasks).where(assigned_tasks: { project_id: @report.project_ids }) : []

      @selected_tasks = @report.task_ids || []

      @TimeFrameOptions = get_timeframe_options
      render :new, status: :unprocessable_entity
    end
  end
  
  def update_projects
    report = UserReport.new
    projects_by_client = User.find(params[:user_id]).projects.group_by(&:client)
    render partial: 'user_reports/projects_cb', locals: { report: report, projects_by_client: projects_by_client }
  end
    
  def update_tasks
    report = UserReport.new
    project_ids = JSON.parse(params[:project_ids_json])
    assigned_tasks = AssignedTask.where(project_id: project_ids).pluck(:task_id)
    tasks = Task.where(id: assigned_tasks)
    selected_tasks = params[:selected_task_ids_json].present? ? params[:selected_task_ids_json] : []
    render partial: 'user_reports/tasks_cb', locals: {report: report, tasks: tasks, selected_tasks: selected_tasks}
  end

  # renders the custome timeframe for the report
  def render_custom_timeframe
    render partial: 'project_reports/timeframe'
  end

  def filtered_params
    params.require(:user_report).permit(:user, :timeframe)
  end
end
