class TimeRegsController < ApplicationController

  require 'csv'

  def show 
  end

  def index 
  end

  def new 
    @client = Client.find(params[:client_id])   
    @project = @client.projects.find(params[:project_id])    
    @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
      .joins(:assigned_tasks).where("project_id = #{@project.id}")        

    @membership = @project.memberships.find_by(user_id: current_user.id)
    @time_reg = @project.time_regs.new

  end
  def create 
    @client = Client.find(params[:client_id])   
    @project = @client.projects.find(params[:project_id])   
    @time_reg = @project.time_regs.build(time_reg_params)

    if @time_reg.save
      redirect_to client_project_path(@client, @project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
      .joins(:assigned_tasks).where("project_id = #{@project.id}")    
    @membership = @project.memberships.find_by(user_id: current_user.id)
    @time_reg = @project.time_regs.find(params[:id])
  end

  def update
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @time_reg = @project.time_regs.find(params[:id])

    if @time_reg.update(time_reg_params)
      redirect_to [@client, @project]
      flash[:notice] = "Time entry has been updated"
    else
      flash[:alert] = "cannot update time entry" 
      render :new, status: :unprocessable_entity
    end
  end

  def destroy 
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @time_reg = @project.time_regs.find(params[:id])

    @time_reg.destroy

    redirect_to [@client, @project], status: :see_other
  end

  def export
    @project = Project.find(params[:project_id])
    @time_regs = @project.time_regs

    csv_data = CSV.generate(headers: true) do |csv|
      # Add CSV header row
      csv << ['id', 'user_id', 'project_id', 'task_id', 'hours', 'created_at', 'updated_at']

      # Add CSV data rows for each time_reg
      @time_regs.each do |time_reg|
        csv << [time_reg.id, time_reg.membership.user_id, time_reg.membership.project_id, time_reg.assigned_task_id, time_reg.minutes, time_reg.created_at, time_reg.updated_at]
      end
    end

    send_data csv_data, filename: "#{Time.now.to_i}_time_regs_for_#{@project.name}.csv"
  end

  private
  def time_reg_params
    params.require(:time_reg).permit(:notes, :minutes, :assigned_task_id, :membership_id)
  end

end
