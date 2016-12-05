defmodule ExampleCode do

  # no favorites - alphabetical order

  def run(squad, genres) do
    Enumj
  end

end

squad = ["Amit", "Andrew", "Arthur", "Dave", "JT", "Larry", "Robin", "Troy", "Ursula"]
genres = ["Alt Rock", "Bluegrass", "Blues", "Bossa Nova", "Country", "Heavy Metal", "Hip Hop", "Jazz", "K-Pop"]

ExampleCode.run(squad, genres)


# Code I Use

|>
fn() -> IO.puts "Test" end
[ head | tail ]
hd()

comprehensions (syntatic sugar for Enum)
for n <- [1, 2, 3, 4], do: n * n
  [1, 4, 9, 16]

Enum.each
Enum.chunk
Enum.count
Enum.group_by
Enum.reduce(3)
Enum.find

Map.keys

GenServer.start_link
GenServer.cast
GenServer.call
handle_cast
handle_call
{:global, NAME}

receive
