#! /usr/bin/env elixir

defmodule Day23 do




  defp read_data(str) do
    str
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end


  defp rotate(current, [current|rest]), do: rest++[current]
  defp rotate(current, [other|rest]), do: rotate(current, rest++[other])

  defp try_insert([], _, _) do
    nil
  end

  defp try_insert([k|rest_deck], k, threes) do
    [k|threes] ++ rest_deck
  end

  defp try_insert([other|rest_deck], k, threes) do
    inserted_rest = try_insert(rest_deck, k, threes)
    if inserted_rest do
      [other|inserted_rest]
    else
      nil
    end
  end

  defp insert(deck, 0, threes), do: insert(deck, Enum.max(deck), threes)
  defp insert(deck, cup, threes) do
    res = try_insert(deck, cup, threes)
    if res do
      res
    else
      insert(deck, cup-1, threes)
    end
  end


  defp move([current, t1, t2, t3|rest]=d) do
    #IO.puts("move #{inspect(d)}")
    deck = [current|rest]
    destination_cup = current-1
    deck = insert(deck, destination_cup, [t1, t2, t3])
    rotate(current, deck)

  end

  defp minus_1([1|deck]), do: deck
  defp minus_1([a|rest]), do: minus_1(rest ++ [a])

  def run_a do
    #deck = read_data("389125467")
    deck = read_data("364297581")
    Enum.reduce(1..100, deck, fn _, d -> move(d) end)
    |> minus_1
    |> Enum.map(&(&1+?0))
    |> IO.puts
  end


  def run_b do
  end
end
