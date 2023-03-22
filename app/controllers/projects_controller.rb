class ProjectsController < ApplicationController
    def index
        @client = Client.find(params[:client_id])
        @projects = @client.projects
    end

    def new
        @client = Client.find(params[:client_id])
        @project = @client.projects.build
    end

    def create
        @client = Client.find(params[:client_id])
        @project = @client.projects.build(project_params)

        if @project.save
            redirect_to client_projects_path(@client)
          else
            render :new, status: :unprocessable_entity
          end
    end

    private
    def project_params
      params.require(:project).permit(:name, :description)
    end
end
