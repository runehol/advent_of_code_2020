#! /usr/bin/env elixir


defmodule Day10 do
  use Memoize

  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defmemo count_combinations(prev, [next]) when next - prev <= 3, do: 1
  defmemo count_combinations(_, [_]), do: 0

  defmemo count_combinations(prev, [next|rest]) do
    if next - prev > 3 do
      0
    else
      count_combinations(prev, rest) + count_combinations(next, rest)
    end
  end

  defp count_combinations([first|rest]), do: count_combinations(first, rest)

  def run_ab do
    adapters = read_data("day10_input.txt")
    last = Enum.max(adapters) + 3

    adapters = Enum.sort([0,last|adapters])
    IO.inspect(adapters)

    differences =
    Enum.zip(adapters, tl(adapters))
    |> Enum.map(fn {smaller, larger} -> larger - smaller end)
    |> Enum.frequencies
    IO.inspect(differences)
    IO.puts(differences[1] * differences[3])

    IO.puts(count_combinations(adapters))
  end



end

Day10.run_ab()
