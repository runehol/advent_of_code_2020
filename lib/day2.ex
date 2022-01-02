#! /usr/bin/env elixir

defmodule Day2 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, min, max, char, pw] = Regex.run(~r/(\d+)-(\d+) (.): (.+)/, line)
      char = hd(String.to_charlist(char))
      {{String.to_integer(min), String.to_integer(max), char}, String.to_charlist(pw)}
    end)
  end

  defp frequencies(pw) do
    Enum.reduce(pw, %{}, fn ch, freqs ->
      Map.update(freqs, ch, 1, &(&1 + 1))
    end)
  end

  defp to_int(false), do: 0
  defp to_int(true), do: 1

  defp is_valid({{min, max, ch}, pw}) do
    freqs = frequencies(pw)
    f = Map.get(freqs, ch, 0)
    to_int(f >= min and f <= max)
  end

  def run_a do
    read_data("data/day2_input.txt")
    |> Enum.map(&is_valid/1)
    |> Enum.sum()
    |> IO.puts()
  end

  defp is_valid_b({{pos1, pos2, ch}, pw}) do
    Bitwise.bxor(to_int(Enum.at(pw, pos1 - 1) == ch), to_int(Enum.at(pw, pos2 - 1) == ch))
  end

  def run_b do
    read_data("data/day2_input.txt")
    |> Enum.map(&is_valid_b/1)
    |> Enum.sum()
    |> IO.puts()
  end
end
