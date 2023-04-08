class AssignedTasksController < ApplicationController
  before_action :authenticate_user!
  def index
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
                          .joins(:assigned_tasks).where("project_id = #{@project.id}")
  end

  def show
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    # @tasks = Task.all
    # @assigned_tasks = AssignedTask.select('name, assigned_tasks.id, project_id, task_id')
    # .joins(:tasks).where("project_id = #{@project.id}")
    @assigned_task = AssignedTask.find(params[:id])
    @task = Task.find(@assigned_task.task_id)
  end

  def new
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @assigned_task = @project.assigned_tasks.build
    @tasks = Task.all
  end

  def create
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @assigned_task = @project.assigned_tasks.build(assigned_task_params)

    if @assigned_task.save
      redirect_to client_project_path(@client, @project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @assigned_task = @project.assigned_tasks.find(params[:id])
    @assigned_task.destroy

    redirect_to client_project_path(@client, @project)
  end

  private

  def assigned_task_params
    params.require(:assigned_task).permit(:project_id, :task_id)
  end
end
