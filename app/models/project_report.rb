class ProjectReport < ApplicationRecord
    validates_presence_of :timeframe, :client, :project, :group_by, :member_ids, :task_ids
end
