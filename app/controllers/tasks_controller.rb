class TasksController < ApplicationController
  before_action :authenticate_user!
  def index
    @tasks = Task.all
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to tasks_path
    else
      render :new, status: :unprocessable_entity
    end
  end 

  def edit
    @is_in_update = true

    puts params.inspect
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      flash[:notice] = 'Task has been updated'
    else
      flash[:alert] = 'Cannot update task'
    end
    redirect_to tasks_path
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    redirect_to tasks_path
  end

  private
  def task_params
    params.require(:task).permit(:name)
  end
end
