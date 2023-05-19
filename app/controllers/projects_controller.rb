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
    # valid_entries tracks how many entries were successfully imported. imported_time_regs is an empty array for all the time regs.
    imported_time_regs = []
    valid_entries = 0

    # if file is empty or missing
    if params[:file].blank?
      flash[:alert] = "Please select a file to import."
      redirect_to projects_path and return
    end

    file = params[:file].read
    CSV.parse(file, headers: true) do |row|
      time_reg_params = row.to_hash.slice('date', 'client', 'project', 'task', 'notes', 'minutes', 'first name', 'last name', 'email')

      # "Renames" date column to date_worked, which is the name used in the database.
      time_reg_params['date_worked'] = row['date']
      time_reg_params.delete('date')

      # Deletes redundant 'client' column and checks if the client exists
      client = row['client']
      check_client client
      time_reg_params.delete('client')

      # Deletes redundant 'project' column and checks if the project exists
      project = row['project']
      check_project project
      time_reg_params.delete('project')

      # Deletes redundant 'task' column and checks if the task exists
      task = row['task']
      check_task task 
      time_reg_params.delete('task')

      # Deletes redundant 'assigned_task' column and checks if the task exists
      check_assigned_task task_id: @task.id
      time_reg_params['assigned_task_id'] = @assigned_task.id
        
      # Deletes redunant name columns
      time_reg_params.delete('first name')
      time_reg_params.delete('last name')

      # Checks if the e-mail and user is valid, and deletes redundant e-mail column
      email = row['email']
      @user = User.find_by(email: email)
      @membership = Membership.find_by(user_id: @user.id, project_id: @project.id)
      time_reg_params.delete('email')
      time_reg_params['membership_id'] = @membership.id
      
      # Checks if the time entries are valid and adds them to the array if they are
      # Also adds 1 to the valid_entries variable
      imported_time_reg = @project.time_regs.new(time_reg_params)
      if imported_time_reg.valid?
        imported_time_regs << imported_time_reg
        valid_entries = valid_entries + 1
      else
        Rails.logger.debug "Invalid time entry: #{imported_time_reg.errors.full_messages}"
      end

      # If any valid time entries have been added, import them
      if imported_time_regs.present?
        TimeReg.import(imported_time_regs)
        flash[:notice] = "#{valid_entries} time entries imported successfully."
      else
        flash[:alert] = "No valid time entries found in the file."
      end
      redirect_to projects_path
      rescue StandardError => e # If the e-mail is invalid, flash and error and redirect
        flash[:alert] = "Invalid e-mail. Please double check the e-mail column for every row."
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

  # Checks to see if the client already exists, and creates it if it doesn't
  def check_client (client)
    if (!Client.exists?(name: client))
      client_params = {"name" => client, "description" => "Description."}
      @client = Client.new(client_params)
      @client.save
     else
      @client = Client.find_by(name: client)
     end
  end

  # Checks to see if the project already exists, and creates it if it doesn't
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

  # Checks to see if the task already exists, and creates it if it doesn't
  def check_task (task)
    if (!Task.exists?(name: task))
      @task = Task.new(name: task)
      @task.save
    else
      @task = Task.find_by(name: task)
    end
  end

  # Checks to see if the assigned task already exists, and creates it if it doesn't  
  def check_assigned_task (task_id)
    if (!@project.assigned_tasks.exists?(task_id))
      @assigned_task = @project.assigned_tasks.build("task_id" => @task.id)
      @assigned_task.save
    else
      @assigned_task = @project.assigned_tasks.find_by(task_id: @task.id)
    end
  end

end
