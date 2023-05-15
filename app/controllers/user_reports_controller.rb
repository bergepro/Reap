class UserReportsController < ApplicationController
    def new
        @report = UserReport.new
        @users = User.all
        @projects_by_client = []
        @tasks = []
    end

    def create
        puts params.inspect
        redirect_to new_user_report_path
    end

    def update_projects
        report = UserReport.new
        projects_by_client = User.find(params[:user_id]).projects.group_by(&:client)
        render partial: 'user_reports/projects_cb', locals: { report: report, projects_by_client: projects_by_client }
      end
      

    def update_tasks
        report = UserReport.new
        project_ids = JSON.parse(params[:project_ids_json])
        assigned_tasks = AssignedTask.where(project_id: project_ids).pluck(:task_id)
        tasks = Task.where(id: assigned_tasks)
        render partial: 'user_reports/tasks_cb', locals: {report: report, tasks: tasks}
    end
end
