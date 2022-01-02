#! /usr/bin/env elixir

defmodule Day4 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.replace("\n", " ")
      |> String.split(" ", trim: true)
      |> Enum.map(fn entry ->
        [k, v] = String.split(entry, ":")
        {String.to_atom(k), v}
      end)
      |> Map.new()
    end)
  end

  defp to_int(false), do: 0
  defp to_int(true), do: 1

  defp valid_a(%{byr: _, iyr: _, eyr: _, hgt: _, hcl: _, ecl: _, pid: _}) do
    true
  end

  defp valid_a(_), do: false

  def run_a do
    read_data("data/day4_input.txt")
    |> Enum.map(&valid_a/1)
    |> Enum.map(&to_int/1)
    |> Enum.sum()
    |> IO.inspect()
  end

  defp valid_int(v, min, max) do
    try do
      val = String.to_integer(v)
      val >= min and val <= max
    rescue
      ArgumentError -> false
    end
  end

  defp valid_eye_color("amb"), do: true
  defp valid_eye_color("blu"), do: true
  defp valid_eye_color("brn"), do: true
  defp valid_eye_color("gry"), do: true
  defp valid_eye_color("grn"), do: true
  defp valid_eye_color("hzl"), do: true
  defp valid_eye_color("oth"), do: true
  defp valid_eye_color(_), do: false

  defp valid_passport_id(pid) do
    Regex.match?(~r/^\d\d\d\d\d\d\d\d\d$/, pid)
  end

  defp valid_hair_color(hcl) do
    Regex.match?(~r/^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$/, hcl)
  end

  defp valid_height(hgt) do
    v = Regex.run(~r/(\d+)(cm|in)/, hgt)

    if v do
      [_, height, measure] = v

      case measure do
        "in" -> valid_int(height, 59, 76)
        "cm" -> valid_int(height, 150, 193)
        _ -> false
      end
    else
      false
    end
  end

  defp valid_b(%{byr: byr, iyr: iyr, eyr: eyr, hgt: hgt, hcl: hcl, ecl: ecl, pid: pid}) do
    valid_int(byr, 1920, 2002) and
      valid_int(iyr, 2010, 2020) and
      valid_int(eyr, 2020, 2030) and
      valid_height(hgt) and
      valid_hair_color(hcl) and
      valid_eye_color(ecl) and
      valid_passport_id(pid)
  end

  defp valid_b(_), do: false

  def run_b do
    read_data("data/day4_input.txt")
    |> Enum.map(&valid_b/1)
    |> Enum.map(&to_int/1)
    |> Enum.sum()
    |> IO.inspect()
  end
end
