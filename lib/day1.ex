#! /usr/bin/env elixir

defmodule Day1 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp maybe_double_sum(a, b) do
    if a + b == 2020 do
      [a * b]
    else
      []
    end
  end

  defp maybe_triple_sum(a, b, c) do
    if a + b + c == 2020 do
      [a * b * c]
    else
      []
    end
  end

  def run_a do
    numbers = read_data("data/day1_input.txt")

    res = for a <- numbers, b <- numbers, do: maybe_double_sum(a, b)

    res
    |> Enum.concat()
    |> Enum.at(0)
    |> IO.inspect()
  end

  def run_b do
    numbers = read_data("data/day1_input.txt")

    res = for a <- numbers, b <- numbers, c <- numbers, do: maybe_triple_sum(a, b, c)

    res
    |> Enum.concat()
    |> Enum.at(0)
    |> IO.inspect()
  end
end
