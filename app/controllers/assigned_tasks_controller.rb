class AssignedTasksController < ApplicationController
  def index
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @tasks = Task.all
    @assigned_tasks = @tasks.joins(:assigned_tasks).where(assigned_tasks: { project_id: @project_id })
  end

  def show
    @assigned_task = Task.find(params[:id])
  end

  def new
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:client_id])
    @assigned_task = @project.assigned_tasks.build
    @tasks = Task.all
  end

  def create
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
    @assigned_task = @project.assigned_tasks.build(assigned_task_params)

    if @assigned_task.save
      redirect_to client_projects_path(@client)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def assigned_task_params
    params.require(:assigned_task).permit(:project_id, :task_id)
  end
end
