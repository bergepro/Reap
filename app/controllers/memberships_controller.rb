class MembershipsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_membership
    
    def new
        puts params.inspect
        @client = Client.find(params[:client_id])
        @project = @client.projects.find(params[:id])
    end

    def create
        @email = membership_params[:email]
        @client = Client.find(params[:client_id])
        @project = @client.projects.find(params[:project_id])

        if User.exists?(email: @email)
            @user = User.find_by(email: @email)
            @membership = @project.memberships.build(user_id: @user.id)

            if @project.memberships.exists?(user_id: @user.id)
                flash[:alert] = "#{@email} is already a member of the project"
            elsif @membership.save
                flash[:notice] = "#{@email} was added to the project"
            end
        else
            flash[:alert] = "#{@email} does not exist"
        end
        redirect_to request.referrer
    end

    def destroy
        @client = Client.find(params[:client_id])
        @project = @client.projects.find(params[:project_id])
        @membership = @project.memberships.find(params[:id])

        if @project.memberships.count <= 1
            flash[:alert] = "cannot remove last member of the project"
        elsif
            flash[:notice] = "Member has been removed from the project"
            @membership.destroy
        end
        redirect_to request.referrer
    end

    private
    def membership_params
        params.require(:membership).permit(:email)
    end

    def ensure_membership
        client = Client.find(params[:client_id])
        project = client.projects.find(params[:project_id])
    
        if !project.memberships.exists?(user_id: current_user)
          flash[:alert] = "Access denied"
          redirect_to root_path
        end
      end

end
