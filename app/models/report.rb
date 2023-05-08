class Report
  include ActiveModel::Model       

  attr_accessor :timeframe, :date_start, :date_end, :client, :project 
  attr_accessor :task_ids, :member_ids
end
