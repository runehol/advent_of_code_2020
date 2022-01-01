#! /usr/bin/env elixir


defmodule Day7 do

  defp read_data(fname) do
     File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, head, contents_str] = Regex.run(~r/^(.+) bags contain (.+)\.$/U, line)
      contents = if contents_str == "no other bags" do
        []
      else
        contents_str
        |> String.split(", ", trim: true)
        |> Enum.map(fn entry ->
          [_, amount_str, kind] = Regex.run(~r/^(\d+) (.+) bags?/U, entry)
          {String.to_integer(amount_str), kind}
        end)
      end
      {head, contents}
    end)
    |> Map.new
  end

  def make_contains_map(rules) do
    rules
    |> Enum.flat_map(fn {head, contents} ->
      contents
      |> Enum.map(fn {_, kind} -> {kind, head} end)
    end)
    |> Enum.reduce(%{}, fn {key, value}, m -> Map.update(m, key, [value], &([value|&1])) end)
  end

  def contains_step(present, contains_map) do
    Enum.concat(present, Enum.flat_map(present, &(Map.get(contains_map, &1, []))))
    |> MapSet.new
  end

  def step_until_stable(present, contains_map) do
    new_present = contains_step(present, contains_map)
    if new_present == present do
      present
    else
      step_until_stable(new_present, contains_map)
    end
  end

  def run_a do
    rules = read_data("day7_input.txt")
    contains_map = make_contains_map(rules)

    initial_set = MapSet.new(["shiny gold"])
    step_until_stable(initial_set, contains_map)
    |> MapSet.difference(initial_set)
    |> MapSet.size
    |> IO.puts

  end

  defp n_bags(kind, rules) do
    1 + Enum.sum(Enum.map(rules[kind], fn {count, subkind} -> count * n_bags(subkind, rules) end))
  end

  def run_b do
    rules = read_data("day7_input.txt")
    IO.puts(n_bags("shiny gold", rules)-1)

  end



end

Day7.run_a()
Day7.run_b()
