class ProjectReportsController < ApplicationController
  before_action :authenticate_user!

  def show
    @failed_update = false
    @report = ProjectReport.find(params[:id])
    @groupes = ["task", "user", "date"]
    @time_regs = get_time_regs(@report)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)
    @TimeFrameOptions = get_timeframe_options
    
    @projects = Project.where(client_id: @report.client)
    @members = Project.find(@report.project).users
    @tasks = Project.find(@report.project).tasks
    @clients = Client.all
  end

  def new
    @clients = Client.all
    @report = ProjectReport.new
    @projects = []
    @members = []
    @tasks = []
    @TimeFrameOptions = get_timeframe_options
  end

  def edit
    @clients = Client.all
    @report = ProjectReport.find(params[:id])
    @projects = Project.where(client_id: @report.client)
    @members = Project.find(@report.project).users
    @tasks = Project.find(@report.project).tasks
    @TimeFrameOptions = get_timeframe_options
  end
  
  def update 
    @report = ProjectReport.find(params[:id])     
    @groupes = ["task", "user", "date"]
    @time_regs = get_time_regs(@report)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)

    @TimeFrameOptions = get_timeframe_options

    @report = set_dates(@report, filtered_params[:timeframe], params[:date_start] || [], params[:date_end] || [])
    
    @report.assign_attributes(filtered_params)      
    @report.member_ids = params[:member_ids] || []
    @report.task_ids = params[:task_ids] || []

    if @report.save
      redirect_to @report
    else
      @failed_update = true
      @clients = Client.all
      @projects = @report.client.present? ? Client.find(@report.client).projects : []
      @members = @report.project.to_i > 0 ? Project.find(@report.project).users : []
      @tasks = @report.project.to_i > 0 ? Project.find(@report.project).tasks : []
      render :show, status: :unprocessable_entity
    end
  end

  def create
    @clients = Client.all
    @TimeFrameOptions = get_timeframe_options
    @report = ProjectReport.new

    @report = set_dates(@report, filtered_params[:timeframe], params[:date_start] || [], params[:date_end] || [])

    @report.assign_attributes(filtered_params)      
    @report.member_ids = params[:member_ids] || []
    @report.task_ids = params[:task_ids] || []
    @report.group_by = "task"

    if @report.save
      redirect_to @report
    else
      @projects = @report.client.present? ? Client.find(@report.client).projects : []
      @tasks = @report.project.present? ? Project.find(@report.project).tasks : []
      @members = @report.project.present? ? Project.find(@report.project).users : []
      render :new, status: :unprocessable_entity
    end
  end


  # ****************
  # helper methods *
  # ****************

  def update_task_checkboxes
    @tasks = Project.find(params[:project_id]).tasks
    render partial: 'project_reports/tasks/checkboxes', locals: { tasks: @tasks }
  end

  def update_member_checkboxes
    @members = Project.find(params[:project_id]).users
    render partial: 'project_reports/members/checkboxes', locals: { members: @members }
  end

  def update_projects_select
    @client = Client.find(params[:client_id])
    @projects= @client.projects.pluck(:name, :id)
    render partial: 'project_reports/projects/select', locals: {projects: @projects}
  end

  def render_custom_timeframe
    render partial: 'project_reports/timeframe'
  end

  def update_group
    @report = ProjectReport.find(params[:project_report_id])
    @report.group_by = params[:group_by]
    @report.save
    redirect_to @report
  end

  def export
    time_regs_ids = JSON.parse(params[:time_reg_ids])
    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      # csv << ['id', 'user_email', 'task_name', 'minutes','created_at', 'updated_at','assigned_task_id', 'user_id', 'membership_id']
      csv << ['date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email']
      # Add CSV data rows for each time_reg
      time_regs_ids.each do |time_reg_id|
        time_reg = TimeReg.find(time_reg_id)

        date = time_reg.date_worked
        client = time_reg.project.client.name
        project = time_reg.project.name
        task = time_reg.assigned_task.task.name
        notes = time_reg.notes
        minutes = time_reg.minutes
        first_name = time_reg.user.first_name
        last_name = time_reg.user.last_name
        email = time_reg.user.email

        csv << [date, client, project, task, notes, minutes, first_name, last_name, email]
      end
    end
    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_custom_report.csv"
  end

  private
  def get_time_regs(report)
    time_regs = TimeReg.includes(:membership, :assigned_task)

    if report.timeframe != "allTime"
      time_regs = time_regs.where(date_worked: report.date_start..report.date_end)
    end
    time_regs = time_regs.where(membership: {user_id: report.member_ids, project_id: report.project})
                         .where(assigned_task: {task_id: report.task_ids})
                         .order(date_worked: :desc, created_at: :desc)
    time_regs.all
  end

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

  def set_dates(report, timeframe, date_start_params, date_end_params)
    if timeframe == "custom"
      report.date_start = Date.new(date_start_params["date_start(1i)"].to_i, 
        date_start_params["date_start(2i)"].to_i, 
        date_start_params["date_start(3i)"].to_i)
      report.date_end = Date.new(date_end_params["date_end(1i)"].to_i, 
        date_end_params["date_end(2i)"].to_i, 
        date_end_params["date_end(3i)"].to_i)
    elsif timeframe == "allTime"
      report.date_start = nil
      report.date_end = nil
    elsif timeframe == nil
      report.timeframe = nil
    else
      report = set_timeframe(report)
    end
    report
  end

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

  def filtered_params
    params.require(:project_report).permit(:timeframe, :client, :project, task_ids: [], member_ids: [])
  end

  def group_time_regs(time_regs, group)
    if group == "task"
      grouped_report = time_regs.group_by { |time_reg| time_reg.task.name }
    elsif group == "user"
      grouped_report = time_regs.group_by { |time_reg| 
        "#{time_reg.user.first_name}
         #{time_reg.user.last_name}" }
    elsif group == "date"
      grouped_report = time_regs.group_by { |time_reg | time_reg.date_worked}
    end
    grouped_report
  end
end
