#! /usr/bin/env elixir

defmodule Day12 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, dir, amount] = Regex.run(~r/(\w)(\d+)/, line)
      {dir, String.to_integer(amount)}
    end)
  end

  def wrap(x) do
    cond do
      x < 0 -> wrap(x + 360)
      x >= 360 -> wrap(x - 360)
      true -> x
    end
  end

  # longitude, latitude, orientation
  @initial_state_v1 {0, 0, 0}
  def do_instruction_v1({"N", amount}, {long, lat, orientation}),
    do: {long, lat - amount, orientation}

  def do_instruction_v1({"S", amount}, {long, lat, orientation}),
    do: {long, lat + amount, orientation}

  def do_instruction_v1({"E", amount}, {long, lat, orientation}),
    do: {long + amount, lat, orientation}

  def do_instruction_v1({"W", amount}, {long, lat, orientation}),
    do: {long - amount, lat, orientation}

  def do_instruction_v1({"R", amount}, {long, lat, orientation}),
    do: {long, lat, wrap(orientation + amount)}

  def do_instruction_v1({"L", amount}, {long, lat, orientation}),
    do: {long, lat, wrap(orientation - amount)}

  def do_instruction_v1({"F", amount}, {_, _, 0} = state),
    do: do_instruction_v1({"E", amount}, state)

  def do_instruction_v1({"F", amount}, {_, _, 90} = state),
    do: do_instruction_v1({"S", amount}, state)

  def do_instruction_v1({"F", amount}, {_, _, 180} = state),
    do: do_instruction_v1({"W", amount}, state)

  def do_instruction_v1({"F", amount}, {_, _, 270} = state),
    do: do_instruction_v1({"N", amount}, state)

  def run_a do
    instructions = read_data("data/day12_input.txt")

    {long, lat, _} = Enum.reduce(instructions, @initial_state_v1, &do_instruction_v1/2)
    IO.puts(abs(long) + abs(lat))
  end

  def rotate({x, y}, 0), do: {x, y}
  def rotate({x, y}, 90), do: {-y, x}
  def rotate({x, y}, 180), do: {-x, -y}
  def rotate({x, y}, 270), do: {y, -x}

  # {longitude, latitude}, {waylong, waylat}
  @initial_state_v2 {{0, 0}, {10, -1}}
  def do_instruction_v2({"N", amount}, {pos, {waylong, waylat}}),
    do: {pos, {waylong, waylat - amount}}

  def do_instruction_v2({"S", amount}, {pos, {waylong, waylat}}),
    do: {pos, {waylong, waylat + amount}}

  def do_instruction_v2({"E", amount}, {pos, {waylong, waylat}}),
    do: {pos, {waylong + amount, waylat}}

  def do_instruction_v2({"W", amount}, {pos, {waylong, waylat}}),
    do: {pos, {waylong - amount, waylat}}

  def do_instruction_v2({"R", amount}, {pos, way}), do: {pos, rotate(way, wrap(amount))}
  def do_instruction_v2({"L", amount}, {pos, way}), do: {pos, rotate(way, wrap(-amount))}

  def do_instruction_v2({"F", amount}, {{poslong, poslat}, {waylong, waylat} = way}),
    do: {{poslong + waylong * amount, poslat + waylat * amount}, way}

  def run_b do
    instructions = read_data("data/day12_input.txt")

    {{long, lat}, _} = Enum.reduce(instructions, @initial_state_v2, &do_instruction_v2/2)
    IO.puts(abs(long) + abs(lat))
  end
end

Day12.run_a()
Day12.run_b()
