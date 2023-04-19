class TimeRegsController < ApplicationController
    before_action :authenticate_user!

    def show 
    end
    
    def index 
    end

    def new 
        @client = Client.find(params[:client_id])   
        @project = @client.projects.find(params[:project_id])    
        @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
        .joins(:assigned_tasks).where("project_id = #{@project.id}")        
        
        @membership = @project.memberships.find_by(user_id: current_user.id)
        @time_reg = @project.time_regs.new

    end
    
    def create 
        @client = Client.find(params[:client_id])   
        @project = @client.projects.find(params[:project_id])   
        @time_reg = @project.time_regs.build(time_reg_params)

        @membership = @project.memberships.find_by(user_id: current_user.id)
        @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
        .joins(:assigned_tasks).where("project_id = #{@project.id}")  

        @time_reg.active = false
        @time_reg.updated = Time.now
        if @time_reg.save
            redirect_to client_project_path(@client, @project)
        else
          render :new, status: :unprocessable_entity
        end
    end

    def edit
        @client = Client.find(params[:client_id])
        @project = @client.projects.find(params[:project_id])
        @assigned_tasks = Task.select('name, assigned_tasks.id, project_id, task_id')
        .joins(:assigned_tasks).where("project_id = #{@project.id}")    
        @membership = @project.memberships.find_by(user_id: current_user.id)
        @time_reg = @project.time_regs.find(params[:id])
    end

    def update
        @client = Client.find(params[:client_id])
        @project = @client.projects.find(params[:project_id])
        @time_reg = @project.time_regs.find(params[:id])

        if @time_reg.update(time_reg_params)
            redirect_to [@client, @project]
            flash[:notice] = "Time entry has been updated"
        else
            flash[:alert] = "cannot update time entry" 
            render :new, status: :unprocessable_entity
        end
    end

    def destroy 
        @client = Client.find(params[:client_id])
        @project = @client.projects.find(params[:project_id])
        @time_reg = @project.time_regs.find(params[:id])

        if @time_reg.destroy
            redirect_to [@client, @project]
            flash[:notice] = "Time entry has been deleted"
        else
            flash[:alert] = "cannot delete time entry" 
            render :new, status: :unprocessable_entity
        end
    end

    def toggle_active
        @client = Client.find(params[:client_id])
        @project = @client.projects.find(params[:project_id])
        @time_reg = @project.time_regs.find(params[:time_reg_id])

        if @time_reg.active
            new_timestamp = Time.now

            old_time = @time_reg.updated.to_i
            new_time = new_timestamp.to_i

            worked_minutes = (new_time - old_time) / 60

            @time_reg.minutes += worked_minutes
            @time_reg.active = false
        else
            @time_reg.updated = Time.now
            @time_reg.active = true
        end
        
        if @time_reg.save
            redirect_to [@client, @project]
        else
            render :new, status: :unprocessable_entity
        end
    end

    private
    def time_reg_params
        params.require(:time_reg).permit(:notes, :minutes, :assigned_task_id, :membership_id)
    end


end
