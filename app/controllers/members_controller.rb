class MembersController < ApplicationController
    def new
        @project = Project.new
    end

    def create
        @email = member_params[:email]

        @project = Project.find(params[:project_id])
        @user = User.find_by(email: @email)
        
        if @user.nil?
            flash[:alert] = "#{@email} does not exist"
        elsif @project.members.exists?(user_id: @user.id)
            flash[:alert] = "#{@email} is already a member of the project"
        else
            @member = @project.members.build(user: @user)
            if @member.save
                flash[:notice] = "#{@email} was added to the project"
            end
        end
        redirect_to request.referrer
    end

    # sletter prosjektet fra databasen
    def destroy
        @project = Project.find(params[:id])
        @member = @project.members.find(params[:project_id])
        if @project.members.count <= 1
            flash[:alert] = "cannot remove last member of the project"
        elsif
            flash[:notice] = "Member has been removed from the project"
            @member.destroy
        end
        redirect_to request.referrer
    end

    private
    def member_params
        params.require(:member).permit(:email)
    end
end
