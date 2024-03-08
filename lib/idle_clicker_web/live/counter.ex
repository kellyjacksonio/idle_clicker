defmodule IdleClickerWeb.Counter do
  use IdleClickerWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    socket =
      socket
      |> assign(:gold, 0)
      |> assign(:idle_purchase_price, 10)
      |> assign(:active_purchase_price, 10)
      |> assign(:idle_amount, 0)
      |> assign(:active_amount, 1)

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    {:noreply, update(socket, :gold, &(&1 + socket.assigns.idle_amount))}
  end

  def handle_event("inc_gold", _, socket) do
    {:noreply, update(socket, :gold, &(&1 + socket.assigns.active_amount))}
  end

  def handle_event("inc_idle_amount", _, socket) do
    if socket.assigns.gold >= socket.assigns.idle_purchase_price do
      new_price = 10

      socket =
        socket
        |> update(:gold, &(&1 - socket.assigns.idle_purchase_price))
        |> update(:idle_amount, &(&1 + 1))
        |> update(:idle_purchase_price, &(&1 + new_price))

      {:noreply, socket}
    else
      # TODO : error, you don't have enough gold?
      {:noreply, socket}
    end
  end

  def handle_event("inc_active_amount", _, socket) do
    if socket.assigns.gold >= socket.assigns.active_purchase_price do
      new_price = 10

      socket =
        socket
        |> update(:gold, &(&1 - socket.assigns.active_purchase_price))
        |> update(:active_amount, &(&1 + 1))
        |> update(:active_purchase_price, &(&1 + new_price))

      {:noreply, socket}
    else
      # TODO : error, you don't have enough gold?
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-4xl font-bold text-center">Gold: <%= @gold %></h1>

      <p class="mt-4 flex flex-col gap-2">
        <.button phx-click="inc_gold">Click to gain <%= @active_amount %> gold</.button>
        <.button phx-click="inc_idle_amount">
          Click to increase gold automation from <%= @idle_amount %> to <%= @idle_amount + 1 %> gold per second (Price: <%= @idle_purchase_price %>)
        </.button>
        <.button phx-click="inc_active_amount">
          Permanently gain <%= @active_amount + 1 %> gold each click (Price: <%= @active_purchase_price %>)
        </.button>
      </p>
    </div>
    """
  end
end
