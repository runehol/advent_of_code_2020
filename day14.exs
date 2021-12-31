#! /usr/bin/env elixir


defmodule Day10 do

  defp parse_mask(line) do
    m = Regex.run(~r/^mask = (\w+)$/, line)
    if m do
      mask = Enum.at(m, 1) |> String.to_charlist()

      force_to_ones = mask
      |> Enum.map(fn ch ->
        if ch == ?1 do
          ?1
        else
          ?0
        end
      end)
      |> List.to_integer(2)

      force_to_zeros = mask
      |> Enum.map(fn ch ->
        if ch == ?0 do
          ?1
        else
          ?0
        end
      end)
      |> List.to_integer(2)
      floating = mask
      |> Enum.map(fn ch ->
        if ch == ?X do
          ?1
        else
          ?0
        end
      end)
      |> List.to_integer(2)
      {:mask, force_to_zeros, force_to_ones, floating}
    else
      nil
    end
  end

  defp parse_set(line) do
    m = Regex.run(~r/mem\[(\d+)\] = (\d+)/, line)
    if m do
      [_, addr, val] = m
      {:set, String.to_integer(addr), String.to_integer((val))}
    else
      nil
    end
  end

  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> parse_mask(line) || parse_set(line) end)
  end

  @initial_state_v1 {0, 0, %{}}
  defp execute_instr_v1({:mask, force_to_zeros, force_to_ones, _}, {_, _, memory}), do: {force_to_zeros, force_to_ones, memory}

  defp execute_instr_v1({:set, addr, value}, {force_to_zeros, force_to_ones, memory}) do
    value = Bitwise.bor(value, force_to_ones)
    value = Bitwise.band(value, Bitwise.bnot(force_to_zeros))
    memory = Map.put(memory, addr, value)
    {force_to_zeros, force_to_ones, memory}
  end

  def run_a do
    instructions = read_data("day14_input.txt")

    {_, _, memory} = Enum.reduce(instructions, @initial_state_v1, &execute_instr_v1/2)

    Map.values(memory) |> Enum.sum |> IO.puts
  end

  # following https://www.chessprogramming.org/Traversing_Subsets_of_a_Set
  defp all_subsets_of_bitset(d) do
    Stream.concat([0], Stream.unfold(Bitwise.band(-d, d), fn
      0 -> nil
      n -> {n, Bitwise.band(n - d, d)}
    end))

  end


  @initial_state_v2 {0, 0, 0, %{}}
  defp execute_instr_v2({:mask, let_through, force_to_one, floating}, {_, _, _, memory}), do: {let_through, force_to_one, floating, memory}

  defp execute_instr_v2({:set, addr, value}, {let_through, force_to_ones, floating, memory}) do
    addr = Bitwise.bor(addr, force_to_ones)
    addr = Bitwise.band(addr, Bitwise.bnot(floating))
    memory = Enum.reduce(all_subsets_of_bitset(floating), memory, fn f, memory ->
      Map.put(memory, Bitwise.bor(addr, f), value)
    end)
    {let_through, force_to_ones, floating, memory}
  end

  def run_b do
    instructions = read_data("day14_input.txt")

    {_, _, _, memory} = Enum.reduce(instructions, @initial_state_v2, &execute_instr_v2/2)


    Map.values(memory) |> Enum.sum |> IO.puts
  end



end

Day10.run_a()
Day10.run_b()
