#! /usr/bin/env elixir

defmodule Day22 do



  defp read_deck(line_str) do
    String.split(line_str, "\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
  end

  defp read_data(fname) do
    tiles =
      File.read!(fname)
      |> String.split("\n\n", trim: true)

    Enum.map(tiles, &read_deck/1) |> List.to_tuple()
  end

  defp score(deck) do
    Enum.with_index([0|Enum.reverse(deck)])
    |> Enum.map(fn {a, b} -> a*b end)
    |> Enum.sum
  end

  defp play([], b) do
    {:b, [], b}
  end

  defp play(a, []) do
    {:a, a, []}
  end

  defp play([a|a_rest], [b|b_rest]) do
    if a > b do
      play(a_rest ++ [a, b], b_rest)
    else
      play(a_rest, b_rest ++ [b, a])
    end
  end
  def run_a do
    {a, b} = read_data("data/day22_input.txt")
    {_, a_win, b_win} = play(a, b)
    s = score(a_win) + score(b_win)
    IO.puts(s)
  end


  defp a_wins_round(round, depth, a, a_rest, b, b_rest, seen_decks) do
    recursive_play(round+1, depth, a_rest ++ [a, b], b_rest, seen_decks)
  end

  defp b_wins_round(round, depth, a, a_rest, b, b_rest, seen_decks) do
    recursive_play(round+1, depth, a_rest, b_rest ++ [b, a], seen_decks)
  end


  defp recursive_play(_, _, [], b, _) do
    {:b, [], b}
  end

  defp recursive_play(_, _, a, [], _) do
    {:a, a, []}
  end


  defp recursive_play(round, depth, [a|a_rest]=a_deck, [b|b_rest]=b_deck, seen_decks) do

    if MapSet.member?(seen_decks, {a_deck, b_deck}) do
      {:a, a_deck, b_deck}
    else
      seen_decks = MapSet.put(seen_decks, {a_deck, b_deck})

      if length(a_rest) >= a and length(b_rest) >= b do
        # recursing
        {winner, _, _} = recursive_play(1, depth+1, Enum.take(a_rest, a), Enum.take(b_rest, b), MapSet.new)
        case winner do
          :a -> a_wins_round(round, depth, a, a_rest, b, b_rest, seen_decks)
          :b -> b_wins_round(round, depth, a, a_rest, b, b_rest, seen_decks)
        end
      else
        if a > b do
          a_wins_round(round, depth, a, a_rest, b, b_rest, seen_decks)
        else
          b_wins_round(round, depth, a, a_rest, b, b_rest, seen_decks)
        end
      end
    end
  end

  def run_b do
    {a, b} = read_data("data/day22_input.txt")
    {_, a_win, b_win} = recursive_play(1, 0, a, b, MapSet.new)
    s = score(a_win) + score(b_win)
    IO.puts(s)
  end
end
