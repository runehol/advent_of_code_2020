#! /usr/bin/env elixir

defmodule Day21 do
  defp read_data(fname) do
    File.read!(fname)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, ingredients_str, allergens_str] = Regex.run(~r/^(.+) \(contains (.+)\)/, line)

      {MapSet.new(String.split(ingredients_str, " ")),
       MapSet.new(String.split(allergens_str, ", "))}
    end)
  end

  def make_allergen_ingredients(foods) do
    Enum.reduce(foods, %{}, fn {ingredients, allergens}, map ->
      Enum.reduce(allergens, map, fn allergen, map ->
        Map.update(map, allergen, ingredients, &MapSet.intersection(&1, ingredients))
      end)
    end)
  end

  def narrow_allergen_ingredients(allergen_ingredients) do
    list =
      Enum.map(allergen_ingredients, fn {allergen, ingredients} ->
        {MapSet.size(ingredients), allergen, ingredients}
      end)
      |> Enum.sort()

    if elem(Enum.at(list, -1), 0) == 1 do
      allergen_ingredients
    else
      to_weed =
        Enum.take_while(list, fn {len, _, _} -> len == 1 end)
        |> Enum.map(fn {_, a, b} -> {a, b} end)
        |> Map.new()

      filter_ingredients = Enum.concat(Map.values(to_weed)) |> MapSet.new()

      weeded_map =
        Enum.map(allergen_ingredients, fn {allergen, ingredients} ->
          {allergen, MapSet.difference(ingredients, filter_ingredients)}
        end)
        |> Map.new()

      weeded_map = Enum.reduce(to_weed, weeded_map, fn {k, v}, m -> Map.put(m, k, v) end)
      narrow_allergen_ingredients(weeded_map)
    end
  end

  def non_allergens(foods) do
    allergen_ingredients = make_allergen_ingredients(foods)
    all_allergens = Enum.reduce(Map.values(allergen_ingredients), &MapSet.union/2)

    Enum.map(foods, fn {ingredients, _} ->
      MapSet.difference(ingredients, all_allergens)
      |> MapSet.size()
    end)
    |> Enum.sum()
  end

  def run_a do
    foods = read_data("data/day21_input.txt")

    IO.puts(non_allergens(foods))
  end

  def run_b do
    foods = read_data("data/day21_input.txt")

    make_allergen_ingredients(foods)
    |> narrow_allergen_ingredients
    |> Enum.sort()
    |> Enum.flat_map(fn {_, ingredients} -> Enum.to_list(ingredients) end)
    |> Enum.join(",")
    |> IO.puts()
  end
end
