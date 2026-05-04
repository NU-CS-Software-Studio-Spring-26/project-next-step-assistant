module HomeHelper
  def deadline_row_class(deadline)
    return "deadline-row-neutral" if deadline.blank?

    days_left = (deadline.to_date - Date.current).to_i

    if days_left < 0
      "deadline-row-danger"
    elsif days_left <= 7
      "deadline-row-warning"
    else
      "deadline-row-success"
    end
  end

  def deadline_status_text(deadline)
    return "No due date" if deadline.blank?

    days_left = (deadline.to_date - Date.current).to_i

    if days_left < 0
      "Overdue"
    elsif days_left == 0
      "Due today"
    elsif days_left <= 7
      "Due soon"
    else
      "#{days_left} days left"
    end
  end
end