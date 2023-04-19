class ProjectsController < ApplicationController
  before_action :authenticate_user!
  def index
    @client = Client.find(params[:client_id])
    @projects = @client.projects.joins(:memberships).where(memberships: { user_id: current_user.id })
  end

  # viser et enkelt prosjekt til bruker .where(assigned_tasks: { project_id: @project.id }
  def show
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:id])
    @tasks = Task.all
    @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
                          .joins(:assigned_tasks).where("project_id = #{@project.id}")
    @time_regs = @project.time_regs.joins(:membership, assigned_task: :task)
                          .where(memberships: { user_id: current_user.id })
                          .order('time_regs.created_at DESC')  
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
    @project = Project.find(params[:id])
    @project.destroy

    redirect_to '/projects#index', status: :see_other
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
