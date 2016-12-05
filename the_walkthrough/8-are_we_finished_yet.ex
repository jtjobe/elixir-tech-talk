#####
##
##  8. ARE WE FINISHED YET
##
######


#
# REPORT_GENERATOR
#

def handle_call({:add_to_finished_reports_count}, _from, state) do
  new_state = [
    total_reports: state[:total_reports],
    finished_reports: state[:finished_reports] + 1,
    start_time: state[:start_time]
  ]

  # for status reporting only
  percent_complete = new_state[:finished_reports] / new_state[:total_reports] * 100
  elapsed_time_in_secs = Interval.new(from: state[:start_time], until: Timex.now) |> Interval.duration(:seconds)
  IO.puts "#{inspect percent_complete}% complete - #{inspect new_state[:finished_reports]} of ~#{inspect new_state[:total_reports]} reports complete - (#{elapsed_time_in_secs} seconds)"
  # end of status reporting

  check_for_finished_report(new_state)
  {:reply, new_state, new_state}
end

defp check_for_finished_report(state) do
  if state[:finished_reports] == state[:total_reports] do
    TcReporter.AgingAccounts.ReportStore.finalize_report
  end
end
