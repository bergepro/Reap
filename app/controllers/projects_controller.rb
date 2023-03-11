class ProjectsController < ApplicationController
    before_action :authenticate_user!
    # henter alle prosjekter til en bruker
    def index
        @projects = current_user.projects
    end

    # viser et enkelt prosjekt til bruker
    def show
        @project = Project.find(params[:id])
        @members = @project.users
    end

    # initialiserer nytt prosjekt
    def new 
        @project = Project.new
    end

    # lager nytt prosjekt i databasen og legger oppretter som member
    def create
        def create
            @project = Project.new(project_params)
            @project.start_date = generate_timestamp

            if @project.save
              @project.members.create(user: current_user)
              redirect_to '/projects#index'
            else
              render :new, status: :unprocessable_entity
            end
          end
    end

    # initialiserer å endre et prosjekt
    def edit        
        @is_in_update = true

        @project = Project.find(params[:id])
    end
    
    # oppdaterer prosjektet i databasen
    def update
        @project = Project.find(params[:id])

        if @project.update(project_params)
            flash[:notice] = "project has been updated"

        else
            flash[:alert] = "cannot update project" 
        end
        redirect_to request.referrer
    end

    # sletter prosjektet fra databasen
    def destroy
        @project = Project.find(params[:id])
        @project.destroy
    
        redirect_to '/projects#index', status: :see_other
    end

    def add_member
        @project = Project.find(params[:id])
        render 'members/new'
    end

    private
    # tillater kun data fra formet med .permit til prosjektopprettelse
    def project_params
      params.require(:project).permit(:name, :description, :client)
    end

    # lager timestamp av tiden nå
    def generate_timestamp
        DateTime.now
    end

 
end
