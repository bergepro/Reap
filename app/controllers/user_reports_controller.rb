class UserReportsController < ReportsController
  GROUPES = {"Client" => "client", "Project" => "project", "Task" => "task", "Date" => "date"} # columns to group report by
  START_GROUP = "date"

  def show
    @report = UserReport.find(params[:id])
    @time_regs = get_time_regs(@report, @report.user_id, @report.project_ids, @report.task_ids)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)

    @show_edit_form = false
    @groupes = GROUPES
    @timeframeOptions = get_timeframe_options
    @users = User.all
    @grouped_projects = User.find(@report.user_id).projects.group_by(&:client)
    @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: {project_id: @report.project_ids}).distinct
    @show_custom_timeframe = @report.timeframe == "custom" ? true : false  
  end

  def new
    @show_custom_timeframe = false
    @report = UserReport.new
    @timeframeOptions = get_timeframe_options
    @users = User.all
    @grouped_projects = []
    @tasks = []
  end

  def create
    @report = UserReport.new(user_report_params)
    @report.group_by = START_GROUP

    set_dates(@report) unless @report.timeframe == "custom"

    if @report.save
      redirect_to @report
    else 
      @show_custom_timeframe = @report.timeframe == "custom" ? true : false
      @timeframeOptions = get_timeframe_options
      @users = User.all
      @grouped_projects = @report.user_id.present? ? User.find(@report.user_id).projects.group_by(&:client) : []
      @tasks = @report.project_ids.present? ? Task.joins(:assigned_tasks).where(assigned_tasks: {project_id: @report.project_ids}).distinct : []
      render :new, status: :unprocessable_entity 
    end
  end

  def edit 
    @report = UserReport.find(params[:id])
    @timeframeOptions = get_timeframe_options
    @users = User.all
    @grouped_projects = User.find(@report.user_id).projects.group_by(&:client)
    @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: {project_id: @report.project_ids}).distinct
    @show_custom_timeframe = @report.timeframe == "custom" ? true : false
  end

  def update
    @report = UserReport.find(params[:id])
    @time_regs = get_time_regs(@report, @report.user_id, @report.project_ids, @report.task_ids)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)

    puts params.inspect

    @report.project_ids = [] unless user_report_params[:user_id] == @report.user_id
    @report.task_ids = [] unless user_report_params[:project_ids].present? 
    
    @report.assign_attributes(user_report_params)

    set_dates(@report) unless @report.timeframe == "custom"

    if @report.save
      redirect_to @report
    else
      @show_edit_form = true
      @groupes = GROUPES
      @show_custom_timeframe = @report.timeframe == "custom" ? true : false
      @timeframeOptions = get_timeframe_options
      @users = User.all
      @grouped_projects = @report.user_id.present? ? User.find(@report.user_id).projects.group_by(&:client) : []
      @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: { project_id: user_report_params[:project_ids] }).distinct
      render :show, status: :unprocessable_entity
    end
  end
 
  # changes the grouping of the report
  def update_group
    # changes the correct report to the new group_by
    @report = UserReport.find(params[:user_report_id])

    puts params.inspect

    if GROUPES.values.include?(params[:group_by])
      @report.group_by = params[:group_by]
      # tries to save the new changes
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

  #********************
  # AJAX form updates *
  # *******************

  def update_projects_checkboxes
    grouped_projects = User.find(params[:user_id]).projects.group_by(&:client)
    render partial: 'projects', locals: {report: UserReport.new, grouped_projects: grouped_projects}
  end

  def update_tasks_checkboxes
    @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: {project_id: params[:project_ids]}).distinct
    render partial: 'tasks', locals: {report: UserReport.new, tasks: @tasks }
  end


  private 

  def user_report_params 
    params.require(:user_report).permit(:timeframe, :date_start, :user_id, :date_end, project_ids: [], task_ids: [])
  end

end
