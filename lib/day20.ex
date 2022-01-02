#! /usr/bin/env elixir

defmodule TileMap do
  defstruct tile_map: %{},
            used_tiles: MapSet.new(),
            v_edges: %{},
            h_edges: %{},
            unfinished_edges: MapSet.new()

  @type edge_map :: %{coord() => {direction(), fingerprint()}}
  @type coord :: {integer(), integer()}
  @type direction :: :low | :high
  @type orientation :: :vertical | :horisontal
  @type fingerprint :: integer()
  @type tile_id :: integer()
  @type tile_signature :: {{integer, integer}, {integer, integer}}
  @type raw_map :: %{coord() => integer()}
  @type oriented_tile :: {tile_id(), tile_signature(), raw_map()}
  @type edge_candidate :: {fingerprint(), direction(), orientation()}
  @type unfinished_edge :: {coord(), edge_candidate()}

  @type t :: %__MODULE__{
          tile_map: %{coord() => {tile_id(), raw_map()}},
          used_tiles: MapSet.t(tile_id()),
          v_edges: edge_map(),
          h_edges: edge_map(),
          unfinished_edges: MapSet.t(unfinished_edge())
        }


  @type tile_candidate_map :: %{edge_candidate() => oriented_tile()}

  @spec new :: TileMap.t()
  def new() do
    %TileMap{}
  end

  @spec insert_edge(
          edge_map(),
          MapSet.t(unfinished_edge()),
          orientation(),
          coord(),
          direction(),
          fingerprint()
        ) ::
          {:error, String.t()} | {:ok, {edge_map(), MapSet.t(unfinished_edge())}}
  defp insert_edge(edge_dict, unfinished_edges, orientation, pos, dir, fingerprint) do
    existing = Map.get(edge_dict, pos, nil)
    edge = {pos, {fingerprint, dir, orientation}}

    case existing do
      ^fingerprint -> {:ok, {edge_dict, MapSet.delete(unfinished_edges, edge)}}
      nil -> {:ok, {Map.put(edge_dict, pos, fingerprint), MapSet.put(unfinished_edges, edge)}}
      _ -> {:error, "Fingerprint mismatch"}
    end
  end

  @spec insert_position(unfinished_edge()) :: coord()
  def insert_position({{y, x}, {_, :low, :vertical}}), do: {y, x}
  def insert_position({{y, x}, {_, :high, :vertical}}), do: {y, x - 1}
  def insert_position({{y, x}, {_, :low, :horisontal}}), do: {y, x}
  def insert_position({{y, x}, {_, :high, :horisontal}}), do: {y - 1, x}

  @spec maybe_insert(t(), coord(), oriented_tile()) ::
          {:ok, t()} | {:error, String.t()}
  def maybe_insert(
        %TileMap{
          tile_map: tile_map,
          used_tiles: used_tiles,
          v_edges: v_edges,
          h_edges: h_edges,
          unfinished_edges: unfinished_edges
        },
        {y, x} = pos,
        {tile_id, {{v_low, v_high}, {h_low, h_high}}, raw_map}
      ) do
    with {:ok, {v_edges, unfinished_edges}} <-
           insert_edge(v_edges, unfinished_edges, :vertical, {y, x}, :high, v_low),
         {:ok, {v_edges, unfinished_edges}} <-
           insert_edge(v_edges, unfinished_edges, :vertical, {y, x + 1}, :low, v_high),
         {:ok, {h_edges, unfinished_edges}} <-
           insert_edge(h_edges, unfinished_edges, :horisontal, {y, x}, :high, h_low),
         {:ok, {h_edges, unfinished_edges}} <-
           insert_edge(h_edges, unfinished_edges, :horisontal, {y + 1, x}, :low, h_high) do
      {:ok, %TileMap{
        tile_map: Map.put(tile_map, pos, {tile_id, raw_map}),
        used_tiles: MapSet.put(used_tiles, tile_id),
        v_edges: v_edges,
        h_edges: h_edges,
        unfinished_edges: unfinished_edges
      }}
    else
      err -> err
    end
  end

  @spec get_extents(TileMap.t()) :: {integer(), integer(), integer(), integer()}
  def get_extents(%TileMap{tile_map: tile_map}) do
    {ys, xs} = Enum.unzip(Map.keys(tile_map))
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)
    min_x = Enum.min(xs)
    max_x = Enum.max(xs)
    {min_y, max_y, min_x, max_x}
  end

  @spec get_corner_product(TileMap.t()) :: integer()
  def get_corner_product(%TileMap{tile_map: tile_map}=m) do
    {min_y, max_y, min_x, max_x} = get_extents(m)

    elem(Map.get(tile_map, {min_y, min_x}), 0) *
    elem(Map.get(tile_map, {min_y, max_x}), 0) *
    elem(Map.get(tile_map, {max_y, min_x}), 0) *
    elem(Map.get(tile_map, {max_y, max_x}), 0)
  end

  @spec assemble_map(t(), integer()) :: raw_map()
  def assemble_map(%TileMap{tile_map: tile_map}, tile_size) do
    Enum.reduce(tile_map, %{}, fn {{tile_y, tile_x}, {_, elements}}, m ->
      Enum.reduce(elements, m, fn {{local_y, local_x}, v}, m ->
        Map.put(m, {tile_y*tile_size + local_y, tile_x*tile_size + local_x}, v)
      end)
    end)

  end
end

defmodule Day20 do
  @tile_size 10

  @spec read_tile(String.t()) :: {TileMap.tile_id(), TileMap.raw_map()}
  defp read_tile(line_str) do
    lines = String.split(line_str, "\n", trim: true)

    [_, id_str] = Regex.run(~r/Tile (\d+):/, hd(lines))
    id = String.to_integer(id_str)

    map =
      Enum.drop(lines, 1)
      |> Enum.with_index(fn line, y ->
        String.to_charlist(line)
        |> Enum.with_index(fn ch, x ->
          if ch == ?# do
            {{y, x}, ?1}
          else
            {{y, x}, ?0}
          end
        end)
      end)
      |> Enum.concat()
      |> Map.new()

    {id, map}
  end

  @spec read_data(String.t()) :: [{TileMap.tile_id(), TileMap.raw_map()}]
  defp read_data(fname) do
    tiles =
      File.read!(fname)
      |> String.split("\n\n", trim: true)

    Enum.map(tiles, &read_tile/1)
  end

  @spec flip_tile(TileMap.raw_map()) :: TileMap.raw_map()
  defp flip_tile(m) do
    for {{y, x}, v} <- m, into: %{}, do: {{x, y}, v}
  end

  @spec rotate_tile_90(TileMap.raw_map()) :: TileMap.raw_map()
  defp rotate_tile_90(m) do
    for {{y, x}, v} <- m, into: %{}, do: {{@tile_size - 1 - x, y}, v}
  end

  @spec all_tile_rotations(TileMap.raw_map()) :: list(TileMap.raw_map())
  defp all_tile_rotations(m) do
    Enum.scan(1..4, m, fn _, m -> rotate_tile_90(m) end)
  end

  @spec all_tile_flips_rotations(TileMap.raw_map()) :: list(TileMap.raw_map())
  def all_tile_flips_rotations(m) do
    Enum.concat(all_tile_rotations(m), all_tile_rotations(flip_tile(m)))
  end

  @spec extract_fingerprint(TileMap.raw_map(), Enum.t(), Enum.t()) :: integer()
  defp extract_fingerprint(m, ys, xs) do
    Enum.zip(ys, xs)
    |> Enum.map(fn {y, x} -> Map.get(m, {y, x}) end)
    |> List.to_integer(2)
  end

  defp repeat(v) do
    Stream.cycle([v])
  end

  @spec extract_signature({TileMap.tile_id(), map}) :: TileMap.oriented_tile()
  def extract_signature({tile_id, m}) do
    max = @tile_size - 1

    {
      tile_id,
      {
        # V
        {extract_fingerprint(m, 0..max, repeat(0)), extract_fingerprint(m, 0..max, repeat(max))},
        # H
        {extract_fingerprint(m, repeat(0), 0..max), extract_fingerprint(m, repeat(max), 0..max)}
      },
      m
    }
  end

  defp append_into_map(m, k, v) do
    Map.update(m, k, [v], &([v|&1]))
  end

  @spec insert_tile(TileMap.tile_candidate_map(), TileMap.tile_id(), TileMap.raw_map()) :: TileMap.tile_candidate_map()
  defp insert_tile(map, tile_id, contents) do
    tile = {_, {{v_low, v_high}, {h_low, h_high}}, _} = extract_signature({tile_id, contents})
    map
    |> append_into_map({v_low, :low, :vertical}, tile)
    |> append_into_map({v_high, :high, :vertical}, tile)
    |> append_into_map({h_low, :low, :horisontal}, tile)
    |> append_into_map({h_high, :high, :horisontal}, tile)
  end

  @spec make_tile_candidate_map([{TileMap.tile_id(), TileMap.raw_map()}]) :: TileMap.tile_candidate_map()
  def make_tile_candidate_map(tiles) do
    Enum.reduce(tiles, %{}, fn {tile_id, contents}, map ->
      Enum.reduce(all_tile_flips_rotations(contents), map, fn contents, map ->
        insert_tile(map, tile_id, contents)
      end)
    end)
  end

  @spec assemble_tiles(integer(), TileMap.t(), TileMap.tile_candidate_map()) :: TileMap.t() | nil
  defp assemble_tiles(0, tile_map, _), do: tile_map

  defp assemble_tiles(n_tiles_left, tile_map, tile_candidate_map) do
    Enum.find_value(tile_map.unfinished_edges, fn {_, cand_sig}=unfinished_edge ->
      candidates = Map.get(tile_candidate_map, cand_sig, [])
      filt_candidates = Enum.filter(candidates, fn {tile_id, _, _} -> !MapSet.member?(tile_map.used_tiles, tile_id) end)
      Enum.find_value(filt_candidates, fn tile ->
        case TileMap.maybe_insert(tile_map, TileMap.insert_position(unfinished_edge), tile) do
          {:ok, new_tile_map} -> assemble_tiles(n_tiles_left-1, new_tile_map, tile_candidate_map)
          {:error, _} -> []
        end
      end)
    end)
  end



  def run_a do
    tiles = read_data("data/day20_test_input.txt")
    tile_candidate_map = make_tile_candidate_map(tiles)
    first_tile = extract_signature(hd(tiles))

    n_tiles = length(tiles)

    {:ok, tile_map} = TileMap.new
    |> TileMap.maybe_insert({0, 0}, first_tile)

    final_tile_map = assemble_tiles(n_tiles-1, tile_map, tile_candidate_map)

    TileMap.get_corner_product(final_tile_map)
    TileMap.assemble_map(final_tile_map, @tile_size)

  end

  def run_b do
  end
end
