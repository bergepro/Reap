class ProjectsController < ApplicationController
  before_action :authenticate_user!


  # viser et enkelt prosjekt til bruker .where(assigned_tasks: { project_id: @project.id }
  def show
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:id])
    @tasks = Task.all
    @assigned_tasks = AssignedTask.select('tasks.name, assigned_tasks.id, assigned_tasks.project_id, assigned_tasks.task_id')
                          .joins(:task)
                          .where(project_id: @project.id)
    @time_regs = @project.time_regs.joins(:membership, assigned_task: :task)
                          .where(memberships: { user_id: current_user.id })
                          .order('time_regs.date_worked DESC', 'tasks.name DESC')
  end

  def new
    @client = Client.find(params[:client_id])
    @project = @client.projects.build
  end

  def create
    @client = Client.find(params[:client_id])
    @project = @client.projects.build(project_params)

    @project.users << current_user

    if @project.save
      redirect_to @client
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    puts params.inspect
    @is_in_update = true

    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:id])
    @assigned_tasks = AssignedTask.select("assigned_tasks.id, tasks.name, project_id").joins("INNER JOIN tasks ON assigned_tasks.task_id = tasks.id")

  end

  def update
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:id])

    if @project.update(project_params)
      flash[:notice] = 'project has been updated'
    else
      flash[:alert] = 'cannot update project'
    end
    redirect_to client_project_path(@client, @project)
  end

  def destroy
    puts "--------------"
    puts params.inspect
    
    @client = Client.find(params[:client_id])
    @project = Project.find(params[:id])
    @project.destroy

    redirect_to @client, status: :see_other
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
