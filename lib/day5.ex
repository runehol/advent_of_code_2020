#! /usr/bin/env elixir

defmodule Day5 do
  defp translate_char(?F), do: ?0
  defp translate_char(?B), do: ?1
  defp translate_char(?L), do: ?0
  defp translate_char(?R), do: ?1

  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
      |> Enum.map(&translate_char/1)
      |> List.to_integer(2)
    end)
  end

  def run_a do
    read_data("data/day5_input.txt")
    |> Enum.max()
    |> IO.puts()
  end

  def run_b do
    lst =
      read_data("data/day5_input.txt")
      |> Enum.sort()

    Enum.zip(lst, tl(lst))
    |> Enum.map(fn {a, b} ->
      if b == a + 2 do
        IO.puts(a + 1)
      end
    end)
  end
end

Day5.run_a()
Day5.run_b()
