#! /usr/bin/env elixir


defmodule Day18 do


  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.to_charlist(line)
      |> Enum.filter(&(&1 != 32))
    end)
  end

  defp term1([v | rest]) when v >= ?0 and v <= ?9, do: {v-?0, rest}
  defp term1([?( | rest]) do
    {value, rest2} = exp1(rest)
    [?) | rest3] = rest2
    {value, rest3}
  end

  defp rest_exp1(value, [?+ | rest]) do
    {value2, rest2} = term1(rest)
    rest_exp1(value+value2, rest2)
  end

  defp rest_exp1(value, [?* | rest]) do
    {value2, rest2} = term1(rest)
    rest_exp1(value*value2, rest2)
  end

  defp rest_exp1(value, tokens) do
    {value, tokens}
  end

  defp exp1(tokens) do
    {value, tokens2} = term1(tokens)
    rest_exp1(value, tokens2)
  end

  defp eval1(tokens) do
    {result, []} = exp1(tokens)
    result
  end

  def run_a do
    lines = read_data("day18_input.txt")
    lines
    |> Enum.map(&eval1/1)
    |> Enum.sum
    |> IO.puts
  end

  defp factor([v | rest]) when v >= ?0 and v <= ?9, do: {v-?0, rest}
  defp factor([?( | rest]) do
    {value, rest2} = exp(rest)
    [?) | rest3] = rest2
    {value, rest3}
  end

  defp rest_term(value, [?+ | rest]) do
    {value2, rest2} = factor(rest)
    rest_term(value+value2, rest2)
  end

  defp rest_term(value, tokens) do
    {value, tokens}
  end

  defp term(tokens) do
    {value, tokens2} = factor(tokens)
    rest_term(value, tokens2)
  end


  defp rest_exp(value, [?* | rest]) do
    {value2, rest2} = term(rest)
    rest_exp(value*value2, rest2)
  end

  defp rest_exp(value, tokens) do
    {value, tokens}
  end

  defp exp(tokens) do
    {value, tokens2} = term(tokens)
    rest_exp(value, tokens2)
  end

  defp eval(tokens) do
    {result, []} = exp(tokens)
    result
  end

  def run_b do
    lines = read_data("day18_input.txt")
    lines
    |> Enum.map(&eval/1)
    |> Enum.sum
    |> IO.puts
  end



end

Day18.run_a()
Day18.run_b()
