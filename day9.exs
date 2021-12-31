#! /usr/bin/env elixir


defmodule Day9 do

  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp find_non_sum([], _, _), do: nil

  defp find_non_sum([value|rest], context, depth) do
    if length(context) < depth do
      find_non_sum(rest, [value|context], depth)
    else
      crosses = for a <- context, b <- context, a+b == value, do: {a,b}
      next_context = Enum.take([value|context], depth)
      if crosses == [] do
        value
      else
        find_non_sum(rest, next_context, depth)
      end
    end
  end

  @infinity 999999999999
  def find_new_sum(stream, needle) do
    {possible_sum, min, max} = Enum.reduce_while(stream, {0, @infinity, -@infinity}, fn elem, {sum, min_val, max_val} ->
      res = {sum+elem, min(min_val, elem), max(max_val, elem)}
      if sum+elem < needle do
        {:cont, res}
      else
        {:halt, res}
      end
    end)
    if possible_sum == needle do
      min+max
    else
      find_new_sum(tl(stream), needle)
    end

  end


  def run_ab do
    stream = read_data("day9_input.txt")
    non_sum = find_non_sum(stream, [], 25)
    IO.puts(non_sum)

    IO.puts(find_new_sum(stream, non_sum))
  end



end

Day9.run_ab()
