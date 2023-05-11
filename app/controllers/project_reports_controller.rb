class ProjectReportsController < ApplicationController
  before_action :authenticate_user!

  GROUPES = ["task", "user", "date"] # columns to group report by
  START_GROUP = "date" # standard grouping when creating new report

  # show report
  def show
    @report = ProjectReport.find(params[:id])

    # data to show the correct time_regs in the report
    @time_regs = get_time_regs(@report)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)


    @failed_update = false # show edit form again?
    # data for the form fields
    @groupes = GROUPES
    @TimeFrameOptions = get_timeframe_options   
    @projects = Project.where(client_id: @report.client)
    @members = Project.find(@report.project).users
    @tasks = Project.find(@report.project).tasks
    @clients = Client.all
  end

  # new report form
  def new
    @report = ProjectReport.new

    # data for the form fields
    @clients = Client.all
    @projects = []
    @members = []
    @tasks = []
    @TimeFrameOptions = get_timeframe_options
  end

  # updates the report with changes
  def update 
    @report = ProjectReport.find(params[:id])     

    # data for the form fields
    @groupes = GROUPES
    @TimeFrameOptions = get_timeframe_options

    # data to show the correct time_regs in the report
    @time_regs = get_time_regs(@report)
    @grouped_report = group_time_regs(@time_regs, @report.group_by)
    
    # gives the report object its attributes
    @report = set_dates(@report, filtered_params[:timeframe], params[:date_start] || [], params[:date_end] || [])
    @report.assign_attributes(filtered_params)      
    @report.member_ids = params[:member_ids] || []
    @report.task_ids = params[:task_ids] || []

    # tries to save the new changes, if not: render edit form with errors
    if @report.save
      redirect_to @report
    else
      @failed_update = true # boolean if the edit-form should be shown again
      
      # renders the selects and checkboxes with the correct content
      @clients = Client.all
      @projects = @report.client.present? ? Client.find(@report.client).projects : []
      @members = @report.project.to_i > 0 ? Project.find(@report.project).users : []
      @tasks = @report.project.to_i > 0 ? Project.find(@report.project).tasks : []

      render :show, status: :unprocessable_entity
    end
  end

  # creates a new report object from the new view
  def create    
    @report = ProjectReport.new

    # gets the correct select data
    @clients = Client.all
    @TimeFrameOptions = get_timeframe_options

    # gives the report object its attributes
    @report = set_dates(@report, filtered_params[:timeframe], params[:date_start] || [], params[:date_end] || [])
    @report.assign_attributes(filtered_params)      
    @report.member_ids = params[:member_ids] || []
    @report.task_ids = params[:task_ids] || []
    @report.group_by = START_GROUP

    # tries to create a new report, if not: render the new view with errors
    if @report.save
      redirect_to @report # sends the user to the report
    else
      # renders the selects and checkboxes with the correct content
      @projects = @report.client.present? ? Client.find(@report.client).projects : []
      @tasks = @report.project.present? ? Project.find(@report.project).tasks : []
      @members = @report.project.present? ? Project.find(@report.project).users : []

      render :new, status: :unprocessable_entity
    end
  end


  # ****************
  # helper methods *
  # ****************

  # finds the tasks from a specific project
  # and renders the tasks as checkboxes
  def update_task_checkboxes
    @tasks = Project.find(params[:project_id]).tasks

    render partial: 'project_reports/tasks/checkboxes', locals: { tasks: @tasks }
  end

  # finds members from a specific project
  # and renders the members as checkboxes
  def update_member_checkboxes
    @members = Project.find(params[:project_id]).users

    render partial: 'project_reports/members/checkboxes', locals: { members: @members }
  end

  # finds the projects with correct columns from a specific client
  # and renders the project-select options
  def update_projects_select
    @client = Client.find(params[:client_id])
    @projects= @client.projects.pluck(:name, :id)

    render partial: 'project_reports/projects/select', locals: {projects: @projects}
  end

  # renders the custome timeframe for the report
  def render_custom_timeframe
    render partial: 'project_reports/timeframe'
  end

  # changes the grouping of the report
  def update_group

    # changes the correct report to the new group_by
    @report = ProjectReport.find(params[:project_report_id])
    @report.group_by = params[:group_by]

    # tries to save the new changes
    if @report.save
      redirect_to @report
    else
      flash[:alert] = "Could not change the grouping"
      redirect_to @report
    end 
  end

  # exports the report to a .CSV
  def export
    time_regs_ids = JSON.parse(params[:time_reg_ids])
    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      # csv << ['id', 'user_email', 'task_name', 'minutes','created_at', 'updated_at','assigned_task_id', 'user_id', 'membership_id']
      csv << ['date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email']
      # Add CSV data rows for each time_reg
      time_regs_ids.each do |time_reg_id|
        time_reg = TimeReg.find(time_reg_id)

        csv << [time_reg.date_worked, time_reg.project.client.name, time_reg.project.name, time_reg.assigned_task.task.name, 
                time_reg.notes, time_reg.minutes, time_reg.user.first_name, time_reg.user.last_name, time_reg.user.email]
      end
    end
    # downloads the report as a .CSV
    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_custom_report.csv"
  end

  private

  # gets all the time_regs for the report with the filters in the report object
  def get_time_regs(report)
    time_regs = TimeReg.includes(:membership, :assigned_task)

    # sets a timeframe unless it is allTime
    if report.timeframe != "allTime"
      time_regs = time_regs.where(date_worked: report.date_start..report.date_end)
    end

    # filters the time_regs to show the correct ones
    time_regs = time_regs.where(membership: {user_id: report.member_ids, project_id: report.project})
                         .where(assigned_task: {task_id: report.task_ids})
                         .order(date_worked: :desc, created_at: :desc)

    time_regs.all
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

  # sets the timeframe for the report if it is custom or allTime
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

  # allowed paramaters to crate :project_report object
  def filtered_params
    params.require(:project_report).permit(:timeframe, :client, :project, task_ids: [], member_ids: [])
  end

  # groupes the time_regs for the different columns
  def group_time_regs(time_regs, group)
    if group == "task"
      grouped_report = time_regs.group_by { |time_reg| time_reg.task.name }
    elsif group == "user"
      grouped_report = time_regs.group_by { |time_reg| "#{time_reg.user.first_name} #{time_reg.user.last_name}" }
    elsif group == "date"
      grouped_report = time_regs.group_by { |time_reg | time_reg.date_worked}
    end

    grouped_report
  end
end
