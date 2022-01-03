#! /usr/bin/env elixir

defmodule Day25 do
  @modulus 20201227
  @spec build_luts(integer, integer, %{integer => integer}, %{integer => integer}) :: {%{integer => integer}, %{integer => integer}}
  def build_luts(value, exp, forward_table, reverse_table) do
    if rem(exp, 1000000) == 0 do
      IO.puts("Building luts: 7**#{exp} == #{value}")
    end
    new_forward_table = Map.put(forward_table, exp, value)
    new_reverse_table = Map.put(reverse_table, value, exp)
    new_exp = exp + 1
    if new_exp == @modulus - 1 do
      {new_forward_table, new_reverse_table}
    else
      new_value = rem(value * 7, @modulus)
      build_luts(new_value, new_exp, new_forward_table, new_reverse_table)
    end
  end

  @spec build_luts :: {%{integer => integer}, %{integer => integer}}
  def build_luts() do
    build_luts(1, 0, %{}, %{})
  end

  @spec encrypt(non_neg_integer, integer()) :: integer()
  def encrypt(0, value), do: value

  def encrypt(loop_size, value) do
    new_value = rem(value*7, @modulus)
    encrypt(loop_size-1, new_value)
  end

  def solve1(key1, key2, {forward_table, reverse_table}) do
    count1 = reverse_table[key1]
    count2 = reverse_table[key2]
    combined_count = rem(count1*count2, @modulus-1)

    encryption_key = forward_table[combined_count]
    IO.puts(encryption_key)
  end

  def run_ab() do
    tables = build_luts()

    #solve1(5764801, 17807724, tables)
    solve1(2959251, 4542595, tables)

  end
end
