#! /usr/bin/env elixir

defmodule Day11 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn line, y ->
      String.to_charlist(line)
      |> Enum.with_index(fn ch, x ->
        case ch do
          ?L -> [{{y, x}, 0}]
          ?# -> [{{y, x}, 1}]
          _ -> []
        end
      end)
    end)
    |> Enum.concat()
    |> Enum.concat()
    |> Map.new()
  end

  @neighbour_dirs [
    {-1, -1},
    {-1, 0},
    {-1, +1},
    {0, -1},
    {0, +1},
    {+1, -1},
    {+1, 0},
    {+1, +1}
  ]

  def neighbours_v1({y, x}) do
    Enum.map(@neighbour_dirs, fn {a, b} -> {y + a, x + b} end)
  end

  defp make_neighbour_map_v1(state) do
    for pos <- Map.keys(state), into: %{}, do: {pos, neighbours_v1(pos)}
  end

  def find_along_dir({y, x}, {dy, dx}, state, max_step) do
    Enum.find_value(1..max_step, [], fn s ->
      p = {y + dy * s, x + dx * s}
      if Map.has_key?(state, p), do: [p]
    end)
  end

  def neighbours_v2(pos, state, max_step) do
    Enum.flat_map(@neighbour_dirs, &find_along_dir(pos, &1, state, max_step))
  end

  defp make_neighbour_map_v2(state) do
    max_step =
      Map.keys(state)
      |> Enum.map(fn {y, x} -> max(y, x) end)
      |> Enum.max()

    for pos <- Map.keys(state), into: %{}, do: {pos, neighbours_v2(pos, state, max_step)}
  end

  defp new_value_v1(pos, 0, state, neighbours) do
    num_full =
      Enum.map(neighbours[pos], &Map.get(state, &1, 0))
      |> Enum.sum()

    if num_full == 0, do: 1, else: 0
  end

  defp new_value_v1(pos, 1, state, neighbours) do
    num_full =
      Enum.map(neighbours[pos], &Map.get(state, &1, 0))
      |> Enum.sum()

    if num_full < 4, do: 1, else: 0
  end

  defp step(state, value_fun, neighbours) do
    for {pos, value} <- state, into: %{}, do: {pos, value_fun.(pos, value, state, neighbours)}
  end

  defp step_until_stable(state, value_fun, neighbours) do
    next_state = step(state, value_fun, neighbours)

    if next_state == state do
      state
    else
      step_until_stable(next_state, value_fun, neighbours)
    end
  end

  def run_a do
    state = read_data("data/day11_input.txt")
    neighbours = make_neighbour_map_v1(state)

    final_state = step_until_stable(state, &new_value_v1/4, neighbours)
    IO.puts(Enum.sum(Map.values(final_state)))
  end

  defp new_value_v2(pos, 0, state, neighbours) do
    num_full =
      Enum.map(neighbours[pos], &Map.get(state, &1, 0))
      |> Enum.sum()

    if num_full == 0, do: 1, else: 0
  end

  defp new_value_v2(pos, 1, state, neighbours) do
    num_full =
      Enum.map(neighbours[pos], &Map.get(state, &1, 0))
      |> Enum.sum()

    if num_full < 5, do: 1, else: 0
  end

  def run_b do
    state = read_data("data/day11_input.txt")
    neighbours = make_neighbour_map_v2(state)

    final_state = step_until_stable(state, &new_value_v2/4, neighbours)
    IO.puts(Enum.sum(Map.values(final_state)))
  end
end
