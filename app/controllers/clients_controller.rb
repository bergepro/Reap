class ClientsController < ApplicationController
    before_action :authenticate_user!
    # henter alle klienter 
    def index
        @clients = Client.all
    end

    # viser et enkelt klient til bruker
    def show
        @client = Client.find(params[:id])
        @projects = current_user.projects.where(projects: {client_id: @client.id})
    end

    # initialiserer nytt klient
    def new 
        @client = Client.new
    end

    # lager nytt klient i databasen og legger oppretter som member
    def create
        @client = Client.new(client_params)

        if @client.save
            redirect_to @client
        else
            render :new, status: :unprocessable_entity
        end
    end

     # initialiserer  klienten
    def edit        
        @client = Client.find(params[:id])
        @projects_exists = @client.projects.exists?
    end
    
    # oppdaterer klient i databasen
    def update
        @client = Client.find(params[:id])

        if @client.update(client_params)
            redirect_to @client
            flash[:notice] = "client has been updated"
        else
            render :new, status: :unprocessable_entity
        end
        # redirect_to request.referrer
    end

    # sletter klient fra databasen
    def destroy
        @client = Client.find(delete_params[:id])
        if delete_params[:confirmation] == "DELETE"
            if @client.destroy
                flash[:notice] = "Project deleted"
                redirect_to projects_path
            else
                flash[:notice] = "Could not delete project"
                render :edit, status: :unprocessable_entity
            end
        else
            flash[:alert] = "Could not confirm"
            render :edit, status: :unprocessable_entity
        end
    end

    private
    # tillater kun data fra formet med .permit til klientopprettelse
    def client_params
      params.require(:client).permit(:name, :description)
    end

    def delete_params
        params.permit(:confirmation, :id)
    end
end
