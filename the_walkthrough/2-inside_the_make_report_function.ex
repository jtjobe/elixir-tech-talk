#####
##
##  2. INSIDE THE MAKE REPORT FUNCTION
##
######

# this shows the basic setup
# all of these are explained in further detail later

def make_report(user_ids, max_date_string_MM_YYYY) do

  # this does simple datetime manipulation to get the very end of a month
  max_date = get_end_of_month_datetime(max_date_string_MM_YYYY)

  # this starts all our GenServers
  start_all_links(max_date)

  # this is responsible for all the processing using our GenServers
  # this is the WORKHORSE, MVP, NUMBA ONE STUNNA
  user_ids
  |> get_user_ids_with_transactions
  |> run_reports_in_batches(max_date)

  # this is a simple process that waits and returns only when
  # all processing is finished and completed reports are ready to return
  wait_for_finished_report

end
