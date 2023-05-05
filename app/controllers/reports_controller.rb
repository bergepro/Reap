class ReportsController < ApplicationController
  def new
    @clients = Client.all

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
end
