#####
##
##  6. THE LITTLE CALCULATOR THAT COULD - aka the first bit of Elixir I wrote...¯\_(ツ)_/¯
##
######

defmodule TcReporter.AgingAccounts.Calculator do
  alias Decimal, as: D
  use Timex

  def run(records, periods) do

    # Part 1:
    # process and prepare all person transactions
    # for an individaul person

    credit_totals_by_period =
      [records, periods]
      |> group_records_by_period
      |> add_missing_periods
      |> sum_credits_by_period

    debit_total = records |> sum_debits

    # Part 2:
    # use the prepared data from above to create the final reports:
    #  - a "FIFO" or first_ifo report
    #  - a "LIFO" or last_ifo report

    reports = [
      first_ifo: first_ifo(debit_total, credit_totals_by_period),
      last_ifo: last_ifo(debit_total, credit_totals_by_period)
    ]

    # Part 3:
    # Send messages/data to our GenServers

    add_results_to_period_sum_store(reports)
    increment_finished_reports_count
  end

  # private


  #
  # FUNCTIONS for PART 1
  # process and prepare all person transactions
  # for an individaul person
  #

  defp group_records_by_period(records_and_periods) do
    [records, periods] = records_and_periods
    Enum.group_by(records, fn(record) ->
      find_period_id_for_record(record.created_at, periods)
    end)
  end

  defp add_missing_periods(records_by_period) do
    Enum.reduce(1..9, records_by_period, fn(period_id, records_by_period) ->
      Map.put_new(records_by_period, period_id, [])
   end)
  end

  defp find_period_id_for_record(created_at, periods) do
    period = Enum.find(periods, fn(period) ->
      [_period_id, start_date, end_date] = period
      Timex.after?(created_at, start_date) && Timex.before?(created_at, end_date)
    end)

    hd(period)
  end

  defp sum_credits_by_period(records_by_period) do
    for {period, records} <- records_by_period, do: [period, sum_credits(records)]
  end

  defp sum_credits(records) do
    Enum.reduce(records, 0, fn(record, sum) ->
      D.add(D.new(record.credit), D.new(sum))
    end)
  end

  defp sum_debits(records) do
    Enum.reduce(records, 0, fn(record, sum) ->
      D.add(D.new(record.debit), D.new(sum))
    end)
  end



  #
  # FUNCTIONS for PART 2
  # use the prepared data from above to create the final reports:
  #  - a "FIFO" or first_ifo report
  #  - a "LIFO" or last_ifo report
  #

  defp first_ifo(debit_total, credit_totals_by_period) do
    first_ifo_ordered_credit_totals = credit_totals_by_period |> Enum.sort |> Enum.reverse
    results = deduct_debits_by_period(debit_total, first_ifo_ordered_credit_totals)

    results[:periods_with_adjusted_totals]
  end

  defp last_ifo(debit_total, credit_totals_by_period) do
    last_ifo_ordered_credit_totals = credit_totals_by_period |> Enum.sort
    results = deduct_debits_by_period(debit_total, last_ifo_ordered_credit_totals)

    results[:periods_with_adjusted_totals]
  end

  defp deduct_debits_by_period(debit_total, credit_totals_by_ordered_periods) do
    acc = [running_total_debit: debit_total, periods_with_adjusted_totals: []]

    Enum.reduce(credit_totals_by_ordered_periods, acc, fn(period_and_total, acc) ->
      [period, credit] = period_and_total

      credit = D.new(credit)
      debit = D.new(acc[:running_total_debit])
      adj_debit = D.sub(debit, credit)
      adj_debit_negative? = D.cmp(adj_debit, D.new(0)) == :lt

      adj_total = if adj_debit_negative?, do: D.abs(adj_debit), else: D.new(0)
      remaining_debit = if adj_debit_negative?, do: D.new(0), else: adj_debit

      period_and_adj_total = [period, adj_total]

      [
       running_total_debit: remaining_debit,
       periods_with_adjusted_totals: [period_and_adj_total | acc[:periods_with_adjusted_totals]]
      ]
    end)
  end



  #
  # FUNCTIONS for PART 3
  # Send messages/data to our GenServers
  #


  # Tell the head-honcho GenServer that another report has finished

  defp increment_finished_reports_count do
    TcReporter.AgingAccounts.ReportGenerator.add_to_finished_reports_count
  end


  # Send 18 values to 18 different period_sum_stores

  defp add_results_to_period_sum_store(reports) do
    Enum.each(reports[:first_ifo], fn(period_and_value) ->
      send_value_to_period_sum_store("FIRST_IFO", period_and_value)
    end)

    Enum.each(reports[:last_ifo], fn(period_and_value) ->
      send_value_to_period_sum_store("LAST_IFO", period_and_value)
    end)
  end

  defp send_value_to_period_sum_store(report, period_and_value) do
    [period, value] = period_and_value
    period_counter_name = "PeriodSumStore:" <> report <> ":" <> Integer.to_string(period)
    TcReporter.AgingAccounts.PeriodSumStore.add({:global, period_counter_name}, value)
  end


end