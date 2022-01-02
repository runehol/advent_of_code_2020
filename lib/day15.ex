#! /usr/bin/env elixir

defmodule Day15 do
  def next({turn, curr, last_seen}) do
    turn = turn + 1
    dist = turn - Map.get(last_seen, curr, turn)
    last_seen = Map.put(last_seen, curr, turn)
    {curr, {turn, dist, last_seen}}
  end

  def preload(values) do
    Enum.reduce(values, {0, 0, %{}}, fn value, {turn, _, last_seen} ->
      st = {turn, value, last_seen}
      {_, st} = next(st)
      st
    end)
  end

  def generate(start_values) do
    Stream.concat(
      start_values,
      Stream.unfold(preload(start_values), &next/1)
    )
  end

  def run_a do
    IO.puts(Enum.at(generate([0, 5, 4, 1, 10, 14, 7]), 2020 - 1))
  end

  def run_b do
    IO.puts(Enum.at(generate([0, 5, 4, 1, 10, 14, 7]), 30_000_000 - 1))
  end
end
