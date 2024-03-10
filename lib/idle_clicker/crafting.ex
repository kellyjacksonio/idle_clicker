defmodule IdleClicker.Crafting do
  def build(crafting_costs, player, item)

  def build(crafting_costs, player, item) do
    item = String.to_atom(item)

    crafting_costs
    |> remove_costs_from_inventory(player, item)
    |> case do
      {:ok, player} -> build_item(player, item)
      {:error, error} -> {:error, error}
    end
  end

  defp remove_costs_from_inventory(crafting_costs, player, item) do
    Enum.reduce_while(crafting_costs[item], {:ok, player}, fn {item_name, cost}, {:ok, player} ->
      player_amount = Map.get(player.inventory, item_name, 0)

      if player_amount >= cost do
        {_, updated_player} = get_and_update_in(player, [Access.key(:inventory), Access.key(item_name)], &{&1, &1 - cost})
        {:cont, {:ok, updated_player}}
      else
        {:halt, {:error, :not_enough_resources}}
      end
    end)
  end

  defp build_item(player, :chest) do
    capacity_updates = %{wood: player.capacity.wood + 25, stone: player.capacity.stone + 25}
    {:ok, %{inventory: player.inventory, capacity: Map.merge(player.capacity, capacity_updates)}}
  end

  defp build_item(player, :house) do
    {:ok, %{has_house: true, inventory: player.inventory}}
  end
end
