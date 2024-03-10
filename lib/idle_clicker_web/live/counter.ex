defmodule IdleClickerWeb.Counter do
  use IdleClickerWeb, :live_view

  alias IdleClicker.Crafting

  @crafting_costs_init %{
    chest: %{
      stone: 25,
      wood: 25
    },
    house: %{
      stone: 100,
      wood: 100
    }
  }

  @player_init %{
    capacity: %{
      wood: 50,
      stone: 50
    },
    has_house: false,
    inventory: %{
      gold: 0,
      fp: 0,
      wood: 0,
      stone: 0
    }
  }

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:player, @player_init)
      |> assign(:crafting_costs, @crafting_costs_init)

    {:ok, socket}
  end

  # TODO: move increase logic elsewhere
  def handle_event(
        "inc_wood",
        _,
        %{assigns: %{player: %{inventory: %{wood: wood}, capacity: %{wood: wood_capacity}}}} =
          socket
      )
      when wood < wood_capacity do
    {:noreply,
     update(
       socket,
       :player,
       fn player ->
         {_updated_value, player} =
           get_and_update_in(player, [Access.key(:inventory), Access.key(:wood)], &{&1, &1 + 1})

         player
       end
     )}
  end

  def handle_event("inc_wood", _, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "inc_stone",
        _,
        %{assigns: %{player: %{inventory: %{stone: stone}, capacity: %{stone: stone_capacity}}}} =
          socket
      )
      when stone < stone_capacity do
        {:noreply,
     update(
       socket,
       :player,
       fn player ->
         {_updated_value, player} =
           get_and_update_in(player, [Access.key(:inventory), Access.key(:stone)], &{&1, &1 + 1})

         player
       end
     )}
  end

  def handle_event("inc_stone", _, socket) do
    {:noreply, socket}
  end

  def handle_event("build", %{"item" => item}, socket) do
    socket.assigns.crafting_costs
    |> Crafting.build(socket.assigns.player, item)
    |> case do
      {:ok, updated_player} -> {:noreply, update(socket, :player, & Map.merge(&1, updated_player) )}
      {:error, _} -> {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-4xl font-bold text-center">
        Wood: <%= @player.inventory.wood %> / <%= @player.capacity.wood %>
      </h1>
      <h1 class="text-4xl font-bold text-center">
        Stone: <%= @player.inventory.stone %> / <%= @player.capacity.stone %>
      </h1>

      <%= if @player.has_house do %>
        <p>Congrats, you won</p>
      <% end %>

      <div class="mt-4 grid grid-cols-3 gap-2">
        <div class="col-span-2 grid grid-cols-1 gap-2">
          <.button phx-click="inc_wood">Chop wood</.button>
          <.button phx-click="inc_stone">Mine stone</.button>
        </div>
        <div class="grid grid-cols-1 gap-2">
          <p>Permanent increase wood and stone capacity by 25</p>
          <.button phx-click="build" phx-value-item="chest">
            Build chest (Cost: <%= @crafting_costs.chest.wood %> wood, <%= @crafting_costs.chest.stone %> stone)
          </.button>
          <%= if !@player.has_house do %>
            <p>Nothing else matters until you have a house!</p>
            <.button phx-click="build" phx-value-item="house">
              Build house (Cost: <%= @crafting_costs.house.wood %> wood, <%= @crafting_costs.house.stone %> stone)
            </.button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
