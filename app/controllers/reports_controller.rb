class ReportsController < ApplicationController
    def index
        @projects = Project.all
      end

    def update_task_checkboxes
        @tasks = Project.find(params[:project_id]).tasks
        render partial: 'reports/tasks/checkboxes', locals: { tasks: @tasks }
    end
    def update_member_checkboxes
        @members = Project.find(params[:project_id]).users
        render partial: 'reports/members/checkboxes', locals: { members: @members }
    end
end
