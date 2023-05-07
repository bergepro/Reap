class Report
  include ActiveModel::Model       
  include ActiveModel::Validations 

  attr_accessor :timeframe, :date_start, :date_end, :client, :project, task_ids: