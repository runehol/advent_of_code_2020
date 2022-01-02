#! /usr/bin/env elixir

defmodule Day24 do
  @neighbours [
    {0, 1},
    {1, 1},
    {1, 0},
    {0, -1},
    {-1, -1},
    {-1, 0}
  ]

  defp parse_dir(""), do: []
  defp parse_dir(<<"w", rest::bitstring>>), do: [{0, 1} | parse_dir(rest)]
  defp parse_dir(<<"nw", rest::bitstring>>), do: [{1, 1} | parse_dir(rest)]
  defp parse_dir(<<"ne", rest::bitstring>>), do: [{1, 0} | parse_dir(rest)]
  defp parse_dir(<<"e", rest::bitstring>>), do: [{0, -1} | parse_dir(rest)]
  defp parse_dir(<<"se", rest::bitstring>>), do: [{-1, -1} | parse_dir(rest)]
  defp parse_dir(<<"sw", rest::bitstring>>), do: [{-1, 0} | parse_dir(rest)]

  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_dir/1)
  end

  defp sum_pos({dy, dx}, {y, x}), do: {dy + y, dx + x}

  defp pos_for_instruction(instrs) do
    Enum.reduce(instrs, {0, 0}, &sum_pos/2)
  end

  defp num_black(map) do
    MapSet.size(map)
  end

  defp flip(pos, m) do
    if MapSet.member?(m, pos) do
      MapSet.delete(m, pos)
    else
      MapSet.put(m, pos)
    end
  end

  defp neighbours(pos) do
    Enum.map(@neighbours, &sum_pos(&1, pos))
  end

  def full_neighbour_set(set) do
    Enum.reduce(set, set, fn pos, set_so_far ->
      Enum.reduce(neighbours(pos), set_so_far, &MapSet.put(&2, &1))
    end)
  end

  defp is_black(tiles, pos) do
    if MapSet.member?(tiles, pos), do: 1, else: 0
  end

  defp n_black_neighbours(tiles, pos) do
    Enum.map(neighbours(pos), &is_black(tiles, &1))
    |> Enum.sum()
  end

  defp maybe_flip(pos, 1, n_black_neighbours, new_tiles)
       when n_black_neighbours == 0 or n_black_neighbours > 2 do
    MapSet.delete(new_tiles, pos)
  end

  defp maybe_flip(pos, 0, n_black_neighbours, new_tiles) when n_black_neighbours == 2 do
    MapSet.put(new_tiles, pos)
  end

  defp maybe_flip(_, _, _, new_tiles), do: new_tiles

  defp step(tiles) do
    extended_positions = full_neighbour_set(tiles)

    Enum.reduce(extended_positions, tiles, fn pos, new_tiles ->
      maybe_flip(pos, is_black(tiles, pos), n_black_neighbours(tiles, pos), new_tiles)
    end)
  end

  def run_ab do
    instructions = read_data("data/day24_input.txt")

    to_flip =
      instructions
      |> Enum.map(&pos_for_instruction/1)

    initial_map = Enum.reduce(to_flip, MapSet.new(), &flip/2)
    IO.puts(num_black(initial_map))

    Enum.reduce(1..100, initial_map, fn _, map -> step(map) end)
    |> num_black
    |> IO.puts()
  end
end
