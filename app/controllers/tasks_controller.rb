class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @tasks = Task.all
    @task = @tasks.build
  end

  def create
    @tasks = Task.all
    @task = @tasks.build(task_params)

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

  private

  def task_params
    params.require(:task).permit(:name)
  end
end
