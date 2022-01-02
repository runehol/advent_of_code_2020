#! /usr/bin/env elixir

defmodule Day6 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn group ->
      group
      |> String.split("\n", trim: true)
      |> Enum.map(fn person ->
        person
        |> String.to_charlist()
        |> MapSet.new()
      end)
    end)
  end

  def run_a do
    groups = read_data("data/day6_input.txt")

    groups
    |> Enum.map(fn group ->
      group
      |> Enum.reduce(&MapSet.union/2)
      |> MapSet.size()
    end)
    |> Enum.sum()
    |> IO.puts()
  end

  def run_b do
    groups = read_data("data/day6_input.txt")

    groups
    |> Enum.map(fn group ->
      group
      |> Enum.reduce(&MapSet.intersection/2)
      |> MapSet.size()
    end)
    |> Enum.sum()
    |> IO.puts()
  end
end

Day6.run_a()
Day6.run_b()
