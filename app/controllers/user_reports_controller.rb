class UserReportsController < ApplicationController
    def new
        @report = UserReport.new
        @users = User.all
        @projects = []
        @tasks = []
    end

    def create
        puts params.inspect
        redirect_to new_user_report_path
    end

    def update_projects
        report = UserReport.new
        projects = User.find(params[:user_id]).projects
        render partial: 'user_reports/projects_cb', locals: {report: report, projects: projects}
    end

    def update_tasks
        report = UserReport.new
        project_ids = JSON.parse(params[:project_ids_json])
        assigned_tasks = AssignedTask.where(project_id: project_ids).pluck(:task_id)
        tasks = Task.where(id: assigned_tasks)
        render partial: 'user_reports/tasks_cb', locals: {report: report, tasks: tasks}
    end
end
