class UserReportsController < ApplicationController
  START_GROUP = "date"

  def show
    @report = UserReport.find(params[:id])
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
    if @report.update(user_report_params)
      redirect_to @report
    else
      @show_custom_timeframe = @report.timeframe == "custom" ? true : false
      @timeframeOptions = get_timeframe_options
      @users = User.all
      @grouped_projects = @report.user_id.present? ? User.find(@report.user_id).projects.group_by(&:client) : []
      @tasks = @report.project_ids.present? ? Task.joins(:assigned_tasks).where(assigned_tasks: {project_id: @report.project_ids}).distinct : []
      render :edit, status: :unprocessable_entity
    end
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

  def get_timeframe_options 
    thisMonthName = I18n.t("date.month_names")[Date.today.month]
    lastMonthName = I18n.t("date.month_names")[Date.today.month-1]
    timeframeOptions = { 
                          "All Time" => 'allTime',
                          "Custom" => 'custom', 
                          "This week" => 'thisWeek',
                          "Last week" => 'lastWeek',
                          "This Month (#{thisMonthName})" => 'thisMonth',
                          "Last month (#{lastMonthName})" => 'lastMonth', 
                        }
  end

  def update_projects_checkboxes
    grouped_projects = User.find(params[:user_id]).projects.group_by(&:client)
    render partial: 'projects', locals: {report: UserReport.new, grouped_projects: grouped_projects}
  end

  def update_tasks_checkboxes
    @tasks = Task.joins(:assigned_tasks).where(assigned_tasks: {project_id: params[:project_ids]}).distinct
    render partial: 'tasks', locals: {report: UserReport.new, tasks: @tasks }
  end

  def user_report_params 
    params.require(:user_report).permit(:timeframe, :date_start, :user_id, :date_end, project_ids: [], task_ids: [])
  end
end
