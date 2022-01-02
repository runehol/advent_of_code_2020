#! /usr/bin/env elixir

defmodule Day8 do
  defp read_data(fname) do
    lines =
      File.read!(fname)
      |> String.split("\n", trim: true)

    instrs =
      lines
      |> Enum.with_index(fn line, idx ->
        [_, cmd_str, val_str] = Regex.run(~r/(acc|jmp|nop) ([+-]?\d+)/, line)
        val = String.to_integer(val_str)

        case cmd_str do
          "nop" -> {idx, {:nop, val}}
          "acc" -> {idx, {:acc, val}}
          "jmp" -> {idx, {:jmp, val}}
        end
      end)
      |> Map.new()

    {instrs, length(lines)}
  end

  def interpret(_, end_pc, {end_pc, acc}, did_visit) do
    {acc, did_visit}
  end

  def interpret(instructions, end_pc, {pc, acc}, did_visit) do
    if MapSet.member?(did_visit, pc) do
      {acc, did_visit}
    else
      {cmd, value} = instructions[pc]

      state =
        case cmd do
          :nop -> {pc + 1, acc}
          :acc -> {pc + 1, acc + value}
          :jmp -> {pc + value, acc}
        end

      interpret(instructions, end_pc, state, MapSet.put(did_visit, pc))
    end
  end

  def print_instruction_set(instructions, set) do
    Enum.to_list(set)
    |> Enum.sort()
    |> Enum.map(fn pc ->
      {cmd, val} = Map.get(instructions, pc, {:out_of_bounds, 0})
      IO.inspect({pc, cmd, val})
    end)
  end

  def next_pc(pc, {:jmp, value}), do: pc + value
  def next_pc(pc, {:acc, _}), do: pc + 1
  def next_pc(pc, {:nop, _}), do: pc + 1

  def reachable(instructions, set0) do
    set =
      Enum.reduce(instructions, set0, fn {pc, instr}, s ->
        if MapSet.member?(s, next_pc(pc, instr)) do
          MapSet.put(s, pc)
        else
          s
        end
      end)

    if set == set0 do
      set
    else
      reachable(instructions, set)
    end
  end

  def run_ab do
    {instructions, end_pc} = read_data("data/day8_input.txt")

    {acc, did_visit} = interpret(instructions, end_pc, {0, 0}, MapSet.new())
    IO.puts("Star 1: #{acc}")

    exit_reachable = reachable(instructions, MapSet.new([end_pc]))

    Enum.each(did_visit, fn pc ->
      {cmd, value} = instructions[pc]
      target = pc + value

      if cmd == :nop and MapSet.member?(exit_reachable, target) do
        IO.puts("Need to patch #{pc} to: #{cmd} #{value}")
      end

      if cmd == :jmp and MapSet.member?(exit_reachable, pc + 1) do
        IO.puts("Need to patch #{pc} to: #{cmd} #{value}")
      end
    end)

    # this is the problem {247, :jmp, 209, 248}
    instructions = Map.put(instructions, 247, {:nop, 209})
    {acc, _} = interpret(instructions, end_pc, {0, 0}, MapSet.new())
    IO.puts("Star 2: #{acc}")
  end
end
