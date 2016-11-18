#####
##
##  9.5. BACK TO WHERE IT ALL STARTED - kazaaam!
##
######


#
# REPORT GENERATOR
#

def make_report(user_ids, max_date_string_MM_YYYY) do
  # max_date = get_end_of_month_datetime(max_date_string_MM_YYYY)

  # start_all_links(max_date)

  # user_ids
  # |> get_user_ids_with_transactions
  # |> run_reports_in_batches(max_date)

  wait_for_finished_report
end

def wait_for_finished_report do
  receive do
    {:finished_report, finished_report} ->
      shutdown_gen_servers
      finished_report
  end
end