#! /usr/bin/env elixir

defmodule Day13 do
  defp read_data(fname) do
    [time, buses_str] =
      File.read!(fname)
      |> String.split("\n", trim: true)

    buses =
      buses_str
      |> String.split(",")
      |> Enum.map(fn
        "x" -> "x"
        v -> String.to_integer(v)
      end)

    {String.to_integer(time), buses}
  end

  def time_until_bus(time, bus_interval) do
    v = rem(time, bus_interval)
    wait = if v == 0, do: 0, else: bus_interval - v
    {wait, bus_interval}
  end

  def run_a do
    {time, buses} = read_data("data/day13_input.txt")

    {wait, id} =
      buses
      |> Enum.filter(&is_integer/1)
      |> Enum.map(&time_until_bus(time, &1))
      |> Enum.min()

    IO.puts(wait * id)
  end

  defp mul_inv(a, _, _, x1) when a <= 1, do: x1

  defp mul_inv(a, b, x0, x1) do
    q = div(a, b)
    mul_inv(b, rem(a, b), x1 - q * x0, x0)
  end

  defp multiplicative_inverse(a, b) do
    x1 = mul_inv(a, b, 0, 1)

    if x1 < 0 do
      x1 + b
    else
      x1
    end
  end

  def chinese_remainder_theorem_solve(mods_remainders) do
    mods = Enum.map(mods_remainders, fn {mod, _} -> mod end)
    prod = Enum.product(mods)

    raw_res =
      mods_remainders
      |> Enum.map(fn {m, r} ->
        p = div(prod, m)
        r * multiplicative_inverse(p, m) * p
      end)
      |> Enum.sum()

    rem(raw_res, prod)
  end

  def run_b do
    {_, buses} = read_data("data/day13_input.txt")

    buses_with_ids =
      buses
      |> Enum.with_index()
      |> Enum.filter(fn {v, _} -> is_integer(v) end)
      |> Enum.map(fn
        {m, 0} -> {m, 0}
        {m, r} -> {m, m - r}
      end)

    first_time = chinese_remainder_theorem_solve(buses_with_ids)
    IO.puts(first_time)
  end
end
