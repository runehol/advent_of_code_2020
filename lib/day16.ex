#! /usr/bin/env elixir

defmodule Day16 do
  use Memoize

  defp parse_tickets(tickets) do
    String.split(tickets, "\n", trim: true)
    # skip header
    |> Enum.drop(1)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp read_data(fname) do
    [rules_str, my_ticket_str, other_tickets_str] =
      File.read!(fname)
      |> String.split("\n\n", trim: true)

    rules =
      rules_str
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [name, rng] = String.split(line, ": ")
        [_, a, b, c, d] = Regex.run(~r/(\d+)-(\d+) or (\d+)-(\d+)/, rng)

        {name,
         [String.to_integer(a)..String.to_integer(b), String.to_integer(c)..String.to_integer(d)]}
      end)

    {rules, hd(parse_tickets(my_ticket_str)), parse_tickets(other_tickets_str)}
  end

  defp all_ranges(rules) do
    Enum.reduce(rules, [], fn {_, ranges}, acc ->
      ranges ++ acc
    end)
  end

  defp matches_ranges(ranges, value) do
    Enum.any?(ranges, &Enum.member?(&1, value))
  end

  defp invalid_rate(all_ranges, ticket) do
    Enum.reduce(ticket, 0, fn value, sum ->
      if matches_ranges(all_ranges, value) do
        sum
      else
        value + sum
      end
    end)
  end

  def run_a do
    {rules, _, other_tickets} = read_data("data/day16_input.txt")
    all_rules = all_ranges(rules)

    other_tickets
    |> Enum.map(&invalid_rate(all_rules, &1))
    |> Enum.sum()
    |> IO.puts()
  end

  def transpose([[] | _]), do: []

  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end

  defp matches_label(field, {label, rule}) do
    if Enum.all?(field, &matches_ranges(rule, &1)) do
      [label]
    else
      []
    end
  end

  defp label_field(field, rules) do
    Enum.flat_map(rules, &matches_label(field, &1))
  end

  defp possible_labels(fields, rules) do
    Enum.map(fields, &label_field(&1, rules))
    |> Enum.with_index(fn options, idx -> {length(options), idx, options} end)
    |> Enum.sort()
  end

  defp assign_labels([], mapping), do: [mapping]

  defp assign_labels([{_, idx, alts} | rest], mapping) do
    alts
    |> Enum.filter(&(!Map.has_key?(mapping, &1)))
    |> Enum.flat_map(fn label ->
      rest_mapping = Map.put(mapping, label, idx)
      assign_labels(rest, rest_mapping)
    end)
  end

  def run_b do
    {rules, my_ticket, other_tickets} = read_data("data/day16_input.txt")
    all_rules = all_ranges(rules)

    valid_tickets = Enum.filter(other_tickets, &(invalid_rate(all_rules, &1) == 0))

    fields = transpose(valid_tickets)
    possible_labels = possible_labels(fields, rules)
    labels = hd(assign_labels(possible_labels, %{}))

    Enum.flat_map(labels, fn {label, idx} ->
      if String.starts_with?(label, "departure") do
        [Enum.fetch!(my_ticket, idx)]
      else
        []
      end
    end)
    |> Enum.product()
    |> IO.puts()
  end
end

Day16.run_a()
Day16.run_b()
