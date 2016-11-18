#####
##
##  7. THE ARMY OF PERIOD SUM STORES - theres like a bunch of them
##
######

defmodule TcReporter.AgingAccounts.PeriodSumStore do
  alias Decimal, as: D
  use GenServer

  # @periods [
  #     "FIRST_IFO:1", "FIRST_IFO:2", "FIRST_IFO:3",
  #     "FIRST_IFO:4", "FIRST_IFO:5", "FIRST_IFO:6",
  #     "FIRST_IFO:7", "FIRST_IFO:8", "FIRST_IFO:9",
  #     "LAST_IFO:1", "LAST_IFO:2", "LAST_IFO:3",
  #     "LAST_IFO:4", "LAST_IFO:5", "LAST_IFO:6",
  #     "LAST_IFO:7", "LAST_IFO:8", "LAST_IFO:9"
  #   ]

  # def start_links do
  #   Enum.each(@periods, fn(counter_name) ->
  #     start_link(counter_name)
  #   end)
  # end

  # def start_link(counter_name) do
  #   name = "PeriodSumStore:" <> counter_name
  #   GenServer.start_link(__MODULE__, 0, name: {:global, name})
  # end

  # def shutdown do
  #   Enum.each(@periods, fn(counter_name) ->
  #     name = "PeriodSumStore:" <> counter_name
  #     GenServer.stop({:global, name})
  #   end)
  # end

  # def init(initial_sum) do
  #   {:ok, initial_sum}
  # end



  def add(pid, value) do
    GenServer.cast(pid, {:add, value})
  end

  def handle_cast({:add, value}, sum) do
    {:noreply, D.add(D.new(sum), D.new(value))}
  end



  def get_sum(pid) do
    GenServer.call(pid, :get_sum)
  end

  def handle_call(:get_sum, _from, sum) do
    {:reply, sum, sum}
  end



end