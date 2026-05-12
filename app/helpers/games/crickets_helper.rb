module Games::CricketsHelper
  def cricket_mark(mark)
    if mark == 3
      mark_icon("three-mark")
    elsif mark == 2
      mark_icon("two-mark")
    elsif mark == 1
      mark_icon("one-mark")
    else
      "-"
    end
  end
end
