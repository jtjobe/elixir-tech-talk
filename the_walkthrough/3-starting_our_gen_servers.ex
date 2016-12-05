#####
##
##  3. STARTING OUR GEN SERVERS
##
######


# THIS FILE CONTAINS CODE FROM MULTIPLE FILES

# grouped together for instructional purposes
# because of similar functionality


## REPORT_GENERATOR.ex ##

def start_all_links(max_date) do
  start_link
  TcReporter.AgingAccounts.ReportStore.start_link(self)
  TcReporter.AgingAccounts.PeriodSumStore.start_links
  TcReporter.AgingAccounts.CalculatorManager.start_link(max_date)
end

def start_link do
  initial_state = [total_reports: 0, finished_reports: 0, start_time: Timex.now]
  GenServer.start_link(__MODULE__, initial_state, name: {:global, AgingAccountsReportGenerator})
end

def init(initial_state) do
  {:ok, initial_state}
end




## REPORT_STORE.ex ##

def start_link(parent_pid) do
  GenServer.start_link(__MODULE__, parent_pid, name: ReportStore)
end

def init(parent_pid) do
  {:ok, parent_pid}
end




## PERIOD_SUM_STORE.ex ##

@periods [
  "FIRST_IFO:1", "FIRST_IFO:2", "FIRST_IFO:3",
  "FIRST_IFO:4", "FIRST_IFO:5", "FIRST_IFO:6",
  "FIRST_IFO:7", "FIRST_IFO:8", "FIRST_IFO:9",
  "LAST_IFO:1", "LAST_IFO:2", "LAST_IFO:3",
  "LAST_IFO:4", "LAST_IFO:5", "LAST_IFO:6",
  "LAST_IFO:7", "LAST_IFO:8", "LAST_IFO:9"
]

def start_links do
  Enum.each(@periods, fn(counter_name) ->
    start_link(counter_name)
  end)
end

def start_link(counter_name) do
  name = "PeriodSumStore:" <> counter_name
  GenServer.start_link(__MODULE__, 0, name: {:global, name})
end

def init(initial_sum) do
  {:ok, initial_sum}
end




## CALCULATOR_MANAGER.ex ##

@period_lengths [30,30,30,90,180,365,365,365,10000]

def start_link(max_date) do
  GenServer.start_link(__MODULE__, max_date, name: {:global, CalculatorManager})
end

def init(max_date) do
  initial_state = [periods: set_periods(max_date, @period_lengths)]
  {:ok, initial_state}
end

defp set_periods(max_date, period_lengths) do
  acc = [working_vars: [0, max_date], periods: []]

  results = Enum.reduce(period_lengths, acc, fn(length, acc) ->
    [period_id, end_date] = acc[:working_vars]
    period_id = period_id + 1
    start_date = Timex.shift(end_date, days: -(length))
    [working_vars: [period_id, start_date], periods: [ [period_id, start_date, end_date] | acc[:periods] ] ]
  end)

  results[:periods]
end



