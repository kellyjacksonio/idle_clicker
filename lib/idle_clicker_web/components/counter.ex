defmodule IdleClickerWeb.Components.Counter do
  use IdleClickerWeb, :live_component

  def update(%{update: true} = assigns, socket) do
    IO.inspect(assigns.drinking_time_left, label: "what is it hahaha")
    {:ok, assign(socket, assigns)}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:pp, 0)
      |> assign(:pp_idle_amount, 0)
      |> assign(:water, 1)
      |> assign(:water_pp, 1)
      |> assign(:water_time, 2)
      |> assign(:drinking_time_left, 0)

    {:ok, socket}
  end

  def handle_event("drink", _, socket) do
    pid = self()

    Task.start(fn ->
      send_update(pid, __MODULE__, [id: "counter", update: true, drinking_time_left: socket.assigns.water_time])
      update_time_left(pid, socket.assigns.water_time)
    end)

    Task.start(fn ->
      send_update_after(pid, __MODULE__, [id: "counter", update: true, drinking_time_left: 0, water: socket.assigns.water + 1, water_pp: socket.assigns.water_pp * 2, water_time: socket.assigns.water_time * 4, pp: socket.assigns.pp + socket.assigns.water_pp], socket.assigns.water_time * 1000)
    end)

    {:noreply, socket}
  end

  def update_time_left(pid, seconds_left) when seconds_left > 0 do
    :timer.sleep(1000)
    send_update(pid, __MODULE__, [id: "counter", update: true, drinking_time_left: seconds_left - 1])

    update_time_left(pid, seconds_left - 1)
  end

  def update_time_left(_pid, seconds_left) when seconds_left == 0 do
    :ok
  end

  def render(assigns) do
    ~H"""
    <div id="counter">
      <h1 class="text-4xl font-bold text-center">
        Positivity points: <%= @pp %>
      </h1>

      <%= @drinking_time_left %>
      <div class="mt-4 grid grid-cols-2 gap-2">
          <button class="bg-blue-500 py-2 px-4 rounded text-white" phx-click="drink" phx-target={@myself} disabled={@drinking_time_left != 0}>Drink <%= @water %> glass(es) of water for <%= @water_pp %> PP </button>
          <button class="bg-yellow-500 py-2 px-4 rounded text-white" phx-click="drink">Coming soon</button>
          <button class="bg-green-500 py-2 px-4 rounded text-white" phx-click="drink">Coming soon</button>
          <button class="bg-red-500 py-2 px-4 rounded text-white" phx-click="drink">Coming soon</button>
      </div>
    </div>
    """
  end
end
