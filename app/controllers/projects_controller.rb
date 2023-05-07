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
    @time_regs = @project.time_regs.joins(:membership, assigned_task: :task)
                          .where(memberships: { user_id: current_user.id })
                          .order('time_regs.date_worked DESC', 'tasks.name DESC')
  end

  def new
    @clients = Client.all
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    @project.users << current_user

    if @project.save
      redirect_to @project
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @is_in_update = true
    @project = Project.find(params[:id])
    @clients = Client.all
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
    @project = Project.find(params[:id])

    if @project.destroy
      flash[:notice] = "Project destroyed"
      redirect_to projects_path
    else
      render :new, status: :unprocessable_entity
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

        puts "csv:"
        puts time_reg_params
        time_reg_params['date_worked'] = row['date']
        time_reg_params.delete('date')
        puts time_reg_params
        puts "WOAA"

        # Client-håndtering
        client = row['client']
        if (!Client.exists?(name: client))
          client_params = {"name" => client, "description" => ""}
          @client = Client.new(client_params)
          @client.save
          puts @client.id
          puts @client.name

          @client.errors.full_messages.each do |message|
            puts message
          end
        else
          @client = Client.find_by(name: client)
        end
        time_reg_params.delete('client')

        # Project-håndtering
        project = row['project']
        if (!Project.exists?(name: project))
          project_params = {"client_id" => @client.id, "name" => project, "description" => ""}
          @project = Project.new(project_params)
          @project.save
          puts @project.id 
          puts @project.name
        else
          @project = Project.find_by(name: project)
        end
        time_reg_params.delete('project')

        # Task-håndtering
        task = row['task']
        if (!Task.exists?(name: task))
          @tasks = Task.all
          @task = @tasks.new(name: task)
          @task.save
        else
          @task = Task.find_by(name: task)
        end

        puts tr ime_reg_params 
        puts @task.id

        # AssignedTask-håndtering
        assigned_task_params = {"project_id" => @project.id, "task_id" => @task.id}
        if (!@project.assigned_tasks.exists?(task_id: @task.id))
          @assigned_task = @project.assigned_tasks.build(assigned_task_params)
          @assigned_task.save
          puts "waaahh"
        else
          @assigned_task = @project.assigned_tasks.find_by(task_id: @task.id)
          puts "wooooo"
        end
        time_reg_params['assigned_task_id'] = @assigned_task.id
        time_reg_params.delete('task')
        puts time_reg_params
        puts "----------------------------"

        time_reg_params.delete('first name')
        time_reg_params.delete('last name')

        email = row['email']
        @user = User.find_by(email: email)
        @membership = Membership.find_by(user_id: @user.id)
        time_reg_params.delete('email')
        time_reg_params['membership_id'] = @membership.id

        puts time_reg_params
        puts "ÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆ"
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
      redirect_to project_path(@project)
      rescue StandardError => e
        flash[:alert] = "There was an error importing the file: #{e.message}"
        redirect_to project_path(@project)
    end
  end

  private

  def project_params
    params.require(:project).permit(:client_id, :name, :description)
  end

  def ensure_membership
    project = Project.find(params[:id])

    if !project.memberships.exists?(user_id: current_user)
      flash[:alert] = "Access denied"
      redirect_to root_path
    end
  end

end
