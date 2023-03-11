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
            flash[:notice] = "#{@email} was added to the project"
            @member = @project.members.create(user: @user)
        end
        redirect_to project_path(@project)
    end

    # sletter prosjektet fra databasen
    def destroy
        @member = Member.find(params[:id])
        @member.destroy
    
        redirect_to '/projects#index', status: :see_other
    end

    private
    def member_params
        params.require(:member).permit(:email)
    end
end
