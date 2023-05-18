class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_membership, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.all
  end
  # viser et enkelt prosjekt til bruker .where(assigned_tasks: { project_id: @project.id }
  def show
    @project = Project.find(params[:id])
    @tasks = Task.all
    @assigned_tasks = AssignedTask.select('tasks.name, assigned_tasks.id, assigned_tasks.project_id, assigned_tasks.task_id')
                          .joins(:task)
                          .where(project_id: @project.id)
  end

  def new
    @clients = Client.all
    @project = Project.new
  end

  def create
    puts "------------"
    puts project_params.inspect 
    @project = Project.new(project_params.except(:task_ids))

    project_params[:task_ids].each do | task_id |
      @project.tasks << Task.find(task_id) if task_id != ""
    end

    @project.users << current_user

    if @project.save
      redirect_to @project
    else
      @clients = Client.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @is_in_update = true
    @project = Project.find(params[:id])
    @clients = Client.all

    @assigned_tasks = AssignedTask.select('tasks.name, assigned_tasks.id, assigned_tasks.project_id, assigned_tasks.task_id')
    .joins(:task)
    .where(project_id: @project.id)

    @assigned_task = @project.assigned_tasks.new
    @tasks = Task.all.where.not(id: @project.assigned_tasks.select(:task_id)).select(:id, :name)  
  end

  def update
    @project = Project.find(params[:id])

    if @project.update(project_params)
      flash[:notice] = 'project has been updated'
    else
      flash[:alert] = 'cannot update project'
    end
    redirect_to @project
  end

  def destroy
    @clients = Client.all
    @project = Project.find(delete_params[:id])
    if delete_params[:confirmation] == "DELETE"
      if @project.destroy
        flash[:notice] = "Project deleted"
        redirect_to projects_path
      else
        flash[:notice] = "Could not delete project"
        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = "Could not confirm"
      render :edit, status: :unprocessable_entity
    end
  end

  def import
    imported_time_regs = []

    if params[:file].blank?
      flash[:alert] = "Please select a file to import."
      redirect_to projects_path and return
    end

    file = params[:file].read
    begin
      CSV.parse(file, headers: true) do |row|
        time_reg_params = row.to_hash.slice('date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email')

        time_reg_params['date_worked'] = row['date']
        time_reg_params.delete('date')

        # Client-håndtering
        client = row['client']
        check_client client
        time_reg_params.delete('client')

        # Project-håndtering
        project = row['project']
        check_project project
        time_reg_params.delete('project')

        # Task-håndtering
        task = row['task']
        check_task task 
        time_reg_params.delete('task')

        # AssignedTask-håndtering
        check_assigned_task task_id: @task.id
        time_reg_params['assigned_task_id'] = @assigned_task.id
        
        time_reg_params.delete('first name')
        time_reg_params.delete('last name')

        email = row['email']
        @user = User.find_by(email: email)
        @membership = Membership.find_by(user_id: @user.id, project_id: @project.id)
        time_reg_params.delete('email')
        time_reg_params['membership_id'] = @membership.id

        imported_time_reg = @project.time_regs.new(time_reg_params)
        if imported_time_reg.valid?
          imported_time_regs << imported_time_reg
        else
          Rails.logger.debug "Invalid time entry: #{imported_time_reg.errors.full_messages}"
        end
      end

      if imported_time_regs.present?
        TimeReg.import(imported_time_regs)
        flash[:notice] = "Time entries imported successfully."
      else
        flash[:alert] = "No valid time entries found in the file."
      end
      redirect_to projects_path
      rescue StandardError => e
        flash[:alert] = "There was an error importing the file: #{e.message}"
        redirect_to projects_path
    end
  end

  private

  def project_params
    if action_name == 'create'
      params.require(:project).permit(:client_id, :name, :description, task_ids: [])
    else
      params.require(:project).permit(:client_id, :name, :description)
    end
  end

  def delete_params
    params.permit(:confirmation, :id)
  end

  def ensure_membership
    project = Project.find(params[:id])

    if !project.memberships.exists?(user_id: current_user)
      flash[:alert] = "Access denied"
      redirect_to root_path
    end
  end

  def check_client (client)
    if (!Client.exists?(name: client))
      client_params = {"name" => client, "description" => "Description."}
      @client = Client.new(client_params)
      @client.save
     else
      @client = Client.find_by(name: client)
     end
  end

  def check_project (project)
    if (!@client.projects.exists?(name: project))
      project_params = {"client_id" => @client.id, "name" => project, "description" => "Description."}
      @project = @client.projects.new(project_params)
      @project.users << current_user
      @project.save
    else
      @project = @client.projects.find_by(name: project)
    end
  end

  def check_task (task)
    if (!Task.exists?(name: task))
      @task = Task.new(name: task)
      @task.save
    else
      @task = Task.find_by(name: task)
    end
  end

  def check_assigned_task (task_id)
    if (!@project.assigned_tasks.exists?(task_id))
      @assigned_task = @project.assigned_tasks.build("task_id" => @task.id)
      @assigned_task.save
    else
      @assigned_task = @project.assigned_tasks.find_by(task_id: @task.id)
    end
  end

end
