#####
##
##  5. OFF TO THE CALCULATOR MANAGER
##
######


defmodule TcReporter.AgingAccounts.CalculatorManager do
  use Timex
  use GenServer

  # @period_lengths [30,30,30,90,180,365,365,365,10000]

  # def start_link(max_date) do
  #   GenServer.start_link(__MODULE__, max_date, name: {:global, CalculatorManager})
  # end

  # def init(max_date) do
  #   initial_state = [periods: set_periods(max_date, @period_lengths)]
  #   {:ok, initial_state}
  # end

  # def shutdown do
  #   GenServer.stop({:global, CalculatorManager})
  # end

  defp run_batch_of_users(records, state) do
    Enum.each(records, fn{user_id, records_for_one_user} ->
      Task.start(
        TcReporter.AgingAccounts.Calculator, :run, [records_for_one_user, state[:periods]]
      )
    end)
  end

  def run_batch(pid, records) do
    GenServer.call(pid, {:run_batch, records})
  end

  def handle_call({:run_batch, records}, _from, state) do
    run_batch_of_users(records, state)
    {:reply, state, state}
  end

  # defp set_periods(max_date, period_lengths) do
  #   acc = [working_vars: [0, max_date], periods: []]

  #   results = Enum.reduce(period_lengths, acc, fn(length, acc) ->
  #     [period_id, end_date] = acc[:working_vars]
  #     period_id = period_id + 1
  #     start_date = Timex.shift(end_date, days: -(length))
  #     [working_vars: [period_id, start_date], periods: [ [period_id, start_date, end_date] | acc[:periods] ] ]
  #   end)

  #   results[:periods]
  # end

end
