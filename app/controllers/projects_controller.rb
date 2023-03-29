class ProjectsController < ApplicationController
  def index
    @client = Client.find(params[:client_id])
    @projects = @client.projects
  end

  # viser et enkelt prosjekt til bruker
  def show
    @project = Project.find(params[:id])
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
      redirect_to client_projects_path(@client)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    puts "hei"
    puts params.inspect
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:id])

  end
  
  def update
    @project = Project.find(params[:id])

    if @project.update(project_params)
      flash[:notice] = "project has been updated"
    else
      flash[:alert] = "cannot update project" 
    end
    redirect_to request.referrer
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
