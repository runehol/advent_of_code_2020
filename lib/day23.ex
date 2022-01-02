#! /usr/bin/env elixir

defmodule Day23 do




  defp read_data(str) do
    str
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end


  defp rotate(current, [current|rest]), do: rest++[current]
  defp rotate(current, [other|rest]), do: rotate(current, rest++[other])

  defp try_insert([k|rest_deck], k, [a, b, c]) do
    [k, a, b, c | rest_deck]
  end

  defp try_insert([other|rest_deck], k, threes) do
    [other|try_insert(rest_deck, k, threes)]
  end

  defp insert(deck, v, [v, _, _]=threes), do: insert(deck, v-1, threes)
  defp insert(deck, v, [_, v, _]=threes), do: insert(deck, v-1, threes)
  defp insert(deck, v, [_, _, v]=threes), do: insert(deck, v-1, threes)
  defp insert(deck, 0, threes), do: insert(deck, Enum.max(deck), threes)
  defp insert(deck, cup, threes) do
    try_insert(deck, cup, threes)
  end


  defp move(_id, [current, t1, t2, t3|rest]) do
    #IO.puts("move #{id}: #{inspect([current, t1, t2, t3|rest])}")
    deck = [current|rest]
    destination_cup = current-1
    deck = insert(deck, destination_cup, [t1, t2, t3])
    rotate(current, deck)

  end

  defp minus_1([1|deck], rev), do: deck ++ Enum.reverse(rev)
  defp minus_1([a|rest], rev), do: minus_1(rest, [a|rev])

  defp minus_1(deck), do: minus_1(deck, [])

  def run_a do
    #deck = read_data("389125467")
    deck = read_data("364297581")
    Enum.reduce(1..100, deck, &move/2)
    |> minus_1
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("")
    |> IO.puts
  end


  def run_b do
    deck = read_data("389125467")
    #deck = read_data("364297581")
    deck = Enum.concat(deck, 10..1000000)

    [a, b | _] = Enum.reduce(1..1000, deck, &move/2)
    |> minus_1
    IO.puts(a*b)
  end
end
