class TasksController < ApplicationController
  def index
    @client = Client.find(params[:client_id])
    @projects = @client.projects
    @tasks = @projects.assigned_tasks
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @project = Project.find(params[:client_id])
    @task = @projects.tasks.build
  end

  def create
    @client = Client.find(params[:client_id])
    @project = @client.projects.build(project_params)

    @project.users << current_user

    if @project.save
      redirect_to client_projects_path(@client)
    else
      render :new, status: :unprocessable_entity
    end
  end
end
