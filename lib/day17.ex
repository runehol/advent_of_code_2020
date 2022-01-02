#! /usr/bin/env elixir

defmodule Day17 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn line, y ->
      String.to_charlist(line)
      |> Enum.with_index(fn ch, x ->
        if ch == ?# do
          [[y, x]]
        else
          []
        end
      end)
    end)
    |> Enum.concat()
    |> Enum.concat()
    |> MapSet.new()
  end

  defp ns([]), do: [[]]

  defp ns([v | rest]) do
    rest_ns = ns(rest)
    for p <- [v - 1, v, v + 1], r <- rest_ns, do: [p | r]
  end

  def neighbours(pos) do
    ns(pos)
    |> Enum.filter(&(&1 != pos))
  end

  def full_neighbour_set(set) do
    Enum.reduce(set, set, fn pos, set_so_far ->
      Enum.reduce(neighbours(pos), set_so_far, &MapSet.put(&2, &1))
    end)
  end

  def should_be_on(pos, set) do
    count =
      Enum.reduce(neighbours(pos), 0, fn p, c ->
        if MapSet.member?(set, p) do
          c + 1
        else
          c
        end
      end)

    if MapSet.member?(set, pos) do
      count == 2 or count == 3
    else
      count == 3
    end
  end

  def step(set) do
    test_set = full_neighbour_set(set)

    Enum.reduce(test_set, MapSet.new(), fn pos, set_so_far ->
      if should_be_on(pos, set) do
        MapSet.put(set_so_far, pos)
      else
        set_so_far
      end
    end)
  end

  defp add_dims(set, extra_dims) do
    for pos <- set, into: MapSet.new(), do: extra_dims ++ pos
  end

  def run_a do
    state = read_data("data/day17_input.txt") |> add_dims([0])

    Enum.reduce(1..6, state, fn _, st ->
      step(st)
    end)
    |> MapSet.size()
    |> IO.puts()
  end

  def run_b do
    state = read_data("data/day17_input.txt") |> add_dims([0, 0])

    Enum.reduce(1..6, state, fn _, st ->
      step(st)
    end)
    |> MapSet.size()
    |> IO.puts()
  end
end

Day17.run_a()
Day17.run_b()
