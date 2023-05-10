class ReportsController < ApplicationController
  before_action :authenticate_user!
  require 'csv'

  def index
    report_attr = session[:report] 
    @groupes = ["task", "user", "date"]

    if report_attr
      report = Report.new(report_attr)
    end

    @group_name = params[:grouping] || "task"
    if @group_name == ""
      @group_name = params[:old_group]
    end

    @time_regs = get_time_regs(report)
    @grouped_report = group_time_regs(@time_regs, @group_name)
  end

  def new
    @clients = Client.all
    @report = ProjectReport.new

    thisMonthName = I18n.t("date.month_names")[Date.today.month]
    lastMonthName = I18n.t("date.month_names")[Date.today.month-1]
    @TimeFrameOptions = { 
                          "Custom" => 'custom', 
                          "This week" => 'thisWeek',
                          "Last week" => 'lastWeek',
                          "This Month (#{thisMonthName})" => 'thisMonth',
                          "Last month (#{lastMonthName})" => 'lastMonth',
                          "All Time" => 'allTime'
                        }
  end

  def create
    puts '---------------'
    puts params.inspect

    @report = Report.new(filtered_params)

    if @report.timeframe == "custom"
      date_start_params = params[:date_start]
      date_end_params = params[:date_end]
      @report.date_start = Date.new(date_start_params["date_start(1i)"].to_i, 
                                    date_start_params["date_start(2i)"].to_i, 
                                    date_start_params["date_start(3i)"].to_i)

      @report.date_end = Date.new(date_end_params["date_end(1i)"].to_i, 
                                  date_end_params["date_end(2i)"].to_i, 
                                  date_end_params["date_end(3i)"].to_i)
    elsif @report.timeframe == "allTime"
      @report.date_start = nil
      @report.date_end = nil
    else
      @report = set_timeframe(@report)
    end
    session[:report] = @report
  
    redirect_to reports_path
  end

  def update_task_checkboxes
    @tasks = Project.find(params[:project_id]).tasks
    render partial: 'reports/tasks/checkboxes', locals: { tasks: @tasks }
  end

  def update_member_checkboxes
    @members = Project.find(params[:project_id]).users
    render partial: 'reports/members/checkboxes', locals: { members: @members }
  end

  def update_projects_select
    @client = Client.find(params[:client_id])
    @projects= @client.projects.pluck(:name, :id)
    render partial: 'reports/projects/select', locals: {projects: @projects}
  end

  def render_custom_timeframe
    render partial: 'reports/timeframe'
  end

  def update_groupes_select
    grouped_report = group_time_regs(@time_regs, params[:grouping])
    render partial: 'reports/report_data', locals: {grouped_report: grouped_report, group_name: params[:grouping]}
  end

  def export
    puts params[:time_regs]
    redirect_to reports_path
  end
  
  def export_test
    time_regs_ids = JSON.parse(params[:time_reg_ids])
    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      # csv << ['id', 'user_email', 'task_name', 'minutes','created_at', 'updated_at','assigned_task_id', 'user_id', 'membership_id']
      csv << ['date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email']
      # Add CSV data rows for each time_reg
      time_regs_ids.each do |time_reg_id|
        time_reg = TimeReg.find(time_reg_id)

        puts date = time_reg.date_worked
        puts client = time_reg.project.client.name
        puts project = time_reg.project.name
        puts task = time_reg.assigned_task.task.name
        puts notes = time_reg.notes
        puts minutes = time_reg.minutes
        puts first_name = time_reg.user.first_name
        puts last_name = time_reg.user.last_name
        puts email = time_reg.user.email

        csv << [date, client, project, task, notes, minutes, first_name, last_name, email]
      end
    end
    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_custom_report.csv"
  end
  

  private
  def filtered_params
    params.permit(:timeframe, :client, :project, task_ids: [], member_ids: [])
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
      
      return report
  end

  def get_time_regs(report)
    time_regs = TimeReg.includes(:membership, :assigned_task)

    if report.timeframe != "allTime"
      time_regs = time_regs.where(date_worked: report.date_start..report.date_end)
    end

    time_regs = time_regs.where(membership: {user_id: report.member_ids})
                         .where(assigned_task: {task_id: report.task_ids})
                         .order(date_worked: :desc, created_at: :desc)

    time_regs.all
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
