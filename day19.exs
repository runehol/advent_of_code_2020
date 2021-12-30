#! /usr/bin/env elixir


defmodule Day19 do


  # Rules database is map of rule_id -> rule
  #a rule is a list of subrules. each subrule is a list of clauses, either {:literal, literal_int} or {:rule, rule_id}

  defp parse_clause("\"" <> <<literal::8>> <> "\"") do
    {:literal, literal}
  end

  defp parse_clause(str) do
    {:rule, String.to_integer(str)}
  end

  defp parse_subrule(str) do
    {:sequence, str
    |> String.split(" ", trim: true)
    |> Enum.map(&parse_clause/1)}
  end

  defp parse_rule(line) do
    [id, subrules] = String.split(line, ":")
    id = String.to_integer(id)
    srs = subrules
    |> String.split("|", trim: true)
    |> Enum.map(&parse_subrule/1)
    {id, {:alternatives, srs}}
  end

  defp read_data(fname) do
    [rules_str, messages_str] = File.read!(fname)
    |> String.split("\n\n", trim: true)

    rules = rules_str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rule/1)
    |> Map.new

    messages = messages_str
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    {rules, messages}
  end


  def parse([head|rest], {:literal, head}, _) do
    rest
  end


  def parse(msg, {:sequence, seq}, rules_db) do
    Enum.reduce(seq, msg, fn rule, msg ->
      seq && parse(msg, rule, rules_db)
    end)
  end

  def parse(msg, {:alternatives, alts}, rules_db) do
    Enum.reduce(alts, nil, fn rule, so_far ->
      so_far || parse(msg, rule, rules_db)
    end)
  end

  def parse(msg, {:rule, rule_id}, rules_db) do
    parse(msg, rules_db[rule_id], rules_db)
  end

  def parse(_, _, _) do
    nil
  end

  def matches?(msg, rule, rules_db) do
    if parse(msg, rule, rules_db) == [] do
      1
    else
      0
    end
  end

  def run_a do
    {rules, msgs} = read_data("day19_input.txt")

    msgs
    |> Enum.map(&(matches?(&1, {:rule, 0}, rules)))
    |> Enum.sum
    |> IO.puts
  end


  def run_b do
  end


end

Day19.run_a()
Day19.run_b()
