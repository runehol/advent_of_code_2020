#! /usr/bin/env elixir

defmodule Day3 do
  defp read_data(fname) do
    lines =
      File.read!(fname)
      |> String.split("\n", trim: true)

    trees =
      lines
      |> Enum.with_index(fn line, y ->
        String.to_charlist(line)
        |> Enum.with_index(fn ch, x ->
          if ch == ?# do
            [{y, x}]
          else
            []
          end
        end)
      end)
      |> Enum.concat()
      |> Enum.concat()
      |> MapSet.new()

    {{length(lines), String.length(hd(lines))}, trees}
  end

  def sample({y, x}, {{_, width}, m}) do
    x = rem(x, width)
    if MapSet.member?(m, {y, x}), do: 1, else: 0
  end

  def check_slope({dy, dx}, {{height, _}, _} = state) do
    Enum.zip(dy..height//dy, dx..(height * dx)//dx)
    |> Enum.map(&sample(&1, state))
    |> Enum.sum()
  end

  def run_a do
    state = read_data("data/day3_input.txt")
    IO.puts(check_slope({1, 3}, state))
  end

  def run_b do
    state = read_data("data/day3_input.txt")

    [{1, 1}, {1, 3}, {1, 5}, {1, 7}, {2, 1}]
    |> Enum.map(&check_slope(&1, state))
    |> Enum.product()
    |> IO.puts()
  end
end

Day3.run_a()
Day3.run_b()
