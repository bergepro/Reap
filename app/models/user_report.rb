class UserReport < ApplicationRecord
    validates_presence_of :timeframe, :user, :group_by, :project_ids, :task_ids
    validate :timeframe_dates_present, if: :custom_timeframe?

    def custom_timeframe?
        timeframe == 'custom'
    end
    
    def timeframe_dates_present
        if date_start.blank? || date_end.blank?
            errors.add(:custom_timeframe, 'requires both start and end dates to be present')
        end
    end
end
