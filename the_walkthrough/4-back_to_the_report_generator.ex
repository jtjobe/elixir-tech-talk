#####
##
##  4. BACK TO THE REPORT GENERATOR
##
######



## REPORT_GENERATOR.ex ##

def make_report(user_ids, max_date_string_MM_YYYY) do
  # ...
  #

  user_ids
  |> get_user_ids_with_transactions
  |> run_reports_in_batches(max_date)

  #
  # ...
end


# STEP 1

  defp get_user_ids_with_transactions(user_ids) do

    if user_ids == ["all"] do

      TcReporter.Repo.all(
        from p in TcReporter.PersonTransactions,
        group_by: p.person_id,
        select: p.person_id
      )

    else

      TcReporter.Repo.all(
        from p in TcReporter.PersonTransactions,
        where: p.person_id in ^user_ids,
        group_by: p.person_id,
        select: p.person_id
      )

    end
  end

# STEP 2

  defp run_reports_in_batches(user_ids, max_date) do
    user_ids
    |> set_total_reports_count
    |> create_batches
    |> run_batches(max_date)
  end

# STEP 2.A

  def set_total_reports_count(user_ids) do
    GenServer.call({:global, AgingAccountsReportGenerator}, {:set_total_reports_count, Enum.count(user_ids)})
    user_ids
  end

  def handle_call({:set_total_reports_count, reports_count}, _from, state) do
    new_state = [total_reports: reports_count, finished_reports: 0, start_time: state[:start_time]]
    {:reply, new_state, new_state}
  end


# STEP 2.B

  defp create_batches(user_ids) do
    Enum.chunk(user_ids, 1_000, 1_000, [])
  end

# STEP 2.C, aka: THE BIG UGLY

  defp run_batches(user_batches, max_date) do
    Enum.each(user_batches, fn(user_batch) ->

      starting_user_count = Enum.count(user_batch)

      active_users = exclude_user_ids_of_locked_accounts(user_batch)

      # this query and group_by transformation excludes users with no transactions before max_date
      records = TcReporter.Repo.all(
                  from p in TcReporter.PersonTransactions,
                  where: p.person_id in ^active_users,
                  where: p.created_at <= ^max_date
                )
                |> Enum.group_by(fn(record) -> record.person_id end)

      user_count_after_exclusions =
        records
        |> Map.keys
        |> Enum.count

      starting_user_count - user_count_after_exclusions |> decrement_total_reports_count


      if Enum.count(records) > 0 do
        TcReporter.AgingAccounts.CalculatorManager.run_batch({:global, CalculatorManager}, records)
      else
        handle_empty_batch
      end

    end)
  end



