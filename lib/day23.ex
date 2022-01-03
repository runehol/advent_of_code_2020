#! /usr/bin/env elixir

defmodule CupGame do
  defstruct entries: %{}, current: 0, max_value: 0

  @type t :: %__MODULE__{
    entries: %{integer() => integer()},
    current: integer(),
    max_value: integer()
  }

  @spec new(list(integer())) :: t()
  def new(init) do
    rotated = Stream.concat(Stream.drop(init, 1), Stream.take(init, 1))
    entries = for v <- Stream.zip(init, rotated), into: %{}, do: v
    current = hd(init)
    max_value = Enum.max(init)
    %CupGame{entries: entries, current: current, max_value: max_value}
  end

  @spec set_current(CupGame.t(), integer()) :: CupGame.t()
  def set_current(game, current) do
    %CupGame{game | current: current}
  end

  @spec extract(t(), integer()|nil, integer()|nil) :: list(integer())
  def extract(game, current \\ nil, n_entries \\ nil) do
    current = current || game.current
    n_entries = n_entries || map_size(game.entries)
    Enum.scan(1..n_entries, current, fn _, v ->
      game.entries[v]
    end)
  end

  @spec extract_but_1(CupGame.t(), nil | integer) :: [integer]
  def extract_but_1(game, size \\ nil) do
    size = size || map_size(game.entries) - 1
    extract(game, 1, size)
  end

  @spec clockwise(t(), integer()) :: integer()
  def clockwise(game, v) do
    game.entries[v]
  end

  @spec pop_clockwise(CupGame.t(), integer()) :: {integer(), CupGame.t()}
  def pop_clockwise(game, pos) do
    n = game.entries[pos]
    nn = game.entries[n]
    new_entries = game.entries
    |> Map.delete(n)
    |> Map.put(pos, nn)

    {n, %CupGame{game | entries: new_entries} }
  end

  @spec push_clockwise(CupGame.t(), integer(), integer()) :: CupGame.t()
  def push_clockwise(game, pos, value) do
    nn = game.entries[pos]
    new_entries = game.entries
    |> Map.put(pos, value)
    |> Map.put(value, nn)
    %CupGame{game | entries: new_entries}
  end

  @spec pop3_clockwise(CupGame.t(), integer) :: {[integer()], CupGame.t()}
  def pop3_clockwise(game, pos) do
    with  {t1, game} <- pop_clockwise(game, pos),
          {t2, game} <- pop_clockwise(game, pos),
          {t3, game} <- pop_clockwise(game, pos)
    do
      {[t1, t2, t3], game}
    end
  end

  @spec push3_clockwise(CupGame.t(), integer(), [integer()]) :: CupGame.t()
  def push3_clockwise(game, pos, [t1, t2, t3]) do
    game = push_clockwise(game, pos, t1)
    game = push_clockwise(game, t1, t2)
    game = push_clockwise(game, t2, t3)

    game
  end

  @spec lower_not_in(t(), integer(), list(integer())) :: integer()
  def lower_not_in(game, 0, not_in), do: lower_not_in(game, game.max_value, not_in)
  def lower_not_in(game, v, not_in)
  do
    if v in not_in do
      lower_not_in(game, v-1, not_in)
    else
      v
    end
  end

  @spec move(integer(), CupGame.t()) :: CupGame.t()
  def move(id, game) do
    if rem(id, 100000) == 0 do
      IO.puts("move #{id}")
    end
    #IO.puts("move #{id}: #{inspect(extract(game))}")
    current = game.current
    {three, game} = pop3_clockwise(game, current)
    destination = lower_not_in(game, current-1, three)
    game = push3_clockwise(game, destination, three)
    game = set_current(game, clockwise(game, current))

    game

  end

end


defmodule Day23 do

  defp read_data(str) do
    str
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end


  def run_a do
    #deck = read_data("389125467")
    deck = read_data("364297581")

    game = CupGame.new(deck)
    Enum.reduce(1..100, game, &CupGame.move/2)
    |> CupGame.extract_but_1
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("")
    |> IO.puts
  end


  def run_b do
    #deck = read_data("389125467")
    deck = read_data("364297581")
    deck = Enum.concat(deck, 10..1000000)
    game = CupGame.new(deck)
    [a, b] = Enum.reduce(1..10000000, game, &CupGame.move/2)
    |> CupGame.extract_but_1(2)
    IO.puts(a*b)
  end
end
