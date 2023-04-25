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
            redirect_to '/clients#index'
        else
            render :new, status: :unprocessable_entity
        end
    end

     # initialiserer  klienten
    def edit        
        @client = Client.find(params[:id])
    end
    
    # oppdaterer klient i databasen
    def update
        @client = Client.find(params[:id])

        if @client.update(client_params)
            redirect_to @client
            flash[:notice] = "client has been updated"
        else
            flash[:alert] = "cannot update client" 
            render :new, status: :unprocessable_entity
        end
        # redirect_to request.referrer
    end

    # sletter klient fra databasen
    def destroy
        @client = Client.find(params[:id])
        @client.destroy
    
        redirect_to '/clients#index', status: :see_other
    end

    private
    # tillater kun data fra formet med .permit til klientopprettelse
    def client_params
      params.require(:client).permit(:name, :description)
    end
end
