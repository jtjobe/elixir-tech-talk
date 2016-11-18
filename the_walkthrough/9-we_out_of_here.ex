#####
##
##  9. WE OUT OF HERE - that's rude, calm down, we're almost finished
##
######

defmodule TcReporter.AgingAccounts.ReportStore do
  use GenServer

  # def start_link(parent_pid) do
  #   GenServer.start_link(__MODULE__, parent_pid, name: ReportStore)
  # end

  # def init(parent_pid) do
  #   {:ok, parent_pid}
  # end

  # def shutdown do
  #   GenServer.stop(ReportStore)
  # end

  def finalize_report do
    GenServer.call(ReportStore, {:finalize_report})
  end

  def handle_call({:finalize_report}, _from, parent_pid) do
    finished_report =
      [
        first_ifo_values: [
          get_sum("FIRST_IFO:1"),
          get_sum("FIRST_IFO:2"),
          get_sum("FIRST_IFO:3"),
          get_sum("FIRST_IFO:4"),
          get_sum("FIRST_IFO:5"),
          get_sum("FIRST_IFO:6"),
          get_sum("FIRST_IFO:7"),
          get_sum("FIRST_IFO:8"),
          get_sum("FIRST_IFO:9")
        ],
        last_ifo_values: [
          get_sum("LAST_IFO:1"),
          get_sum("LAST_IFO:2"),
          get_sum("LAST_IFO:3"),
          get_sum("LAST_IFO:4"),
          get_sum("LAST_IFO:5"),
          get_sum("LAST_IFO:6"),
          get_sum("LAST_IFO:7"),
          get_sum("LAST_IFO:8"),
          get_sum("LAST_IFO:9")
        ]
      ]


    # THIS LITTLE GUY HERE IS THE **** REAL WINNER ****,
    # WITHOUT THIS LITTLE GUY AINT NOTHING EVER GONNA RETURN
    # ................................................................................EVER
    send parent_pid, {:finished_report, finished_report}

    {:reply, finished_report, finished_report}
  end

  def get_sum(report_type_and_period_id) do
    complete_name = "PeriodSumStore:" <> report_type_and_period_id
    sum = TcReporter.AgingAccounts.PeriodSumStore.get_sum({:global, complete_name})

    IO.puts "#{complete_name} -> #{inspect sum}"
    sum
  end
end