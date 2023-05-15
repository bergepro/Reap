class ProjectReportsController < ReportsController

  GROUPES = {"Task" => "task", "Date" => "date", "User" => "user"} # columns to group report by
  START_GROUP = "date" # standard grouping when creating new report

  # show report
  def show
    @show_edit_form = false
    @report = ProjectReport.find(params[:id])
    
    @time_regs = get_time_regs(@report, @report.member_ids, @report.project_id, @report.task_ids)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)
    @groupes = GROUPES

    @timeframeOptions = get_timeframe_options
    @clients = Client.all
    @projects = @clients.find(@report.client_id).projects
    project = Project.find(@report.project_id)
    @members = project.users
    @tasks = project.tasks
  end

  def update
    @report = ProjectReport.find(params[:id])
    @time_regs = get_time_regs(@report, @report.member_ids, @report.project_id, @report.task_ids)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)


    @report.member_ids = [] unless project_report_params[:member_ids].present?
    @report.task_ids = [] unless project_report_params[:task_ids].present? 

    @report.assign_attributes(project_report_params.except(:project_id))
    @report.project_id = Project.exists?(project_report_params[:project_id]) ? project_report_params[:project_id] : nil

    set_dates(@report) unless @report.timeframe == "custom"

    if @report.save
      redirect_to @report
    else
      @show_edit_form = true
      @groupes = GROUPES
      @show_custom_timeframe = @report.timeframe == "custom" ? true : false
      @timeframeOptions = get_timeframe_options
      @clients = Client.all
      @projects = @report.client_id.present? ? Client.find(@report.client_id).projects : []
      if @report.project_id.present?
        project = Project.find(@report.project_id)
        @members = @report.member_ids.present? ? project.users : []
        @tasks = @report.task_ids.present? ? project.tasks : []
      else
        @members = []
        @tasks = []
      end
      render :show, status: :unprocessable_entity
    end
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
        project = Project.find(@report.project_id)
        @members = @report.member_ids.present? ? project.users : []
        @tasks = @report.task_ids.present? ? project.tasks : []   
      else 
        @members = []
        @tasks = []
      end
      render :new, status: :unprocessable_entity 
    end
  end

  def update_group
    @report = ProjectReport.find(params[:project_report_id])
    if GROUPES.values.include?(params[:group_by])
      @report.group_by = params[:group_by]
      if @report.save
        redirect_to @report
      else
        flash[:alert] = "Could not change the grouping"
        redirect_to @report
      end 
    else
      flash[:alert] = "Invalid group"
      redirect_to @report    
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
