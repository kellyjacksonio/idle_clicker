defmodule IdleClickerWeb.Counter do
  use IdleClickerWeb, :live_view

  alias IdleClickerWeb.Components.Counter

  def render(assigns) do
    ~H"""
    <div>
      <.live_component module={Counter} id="counter" />
    </div>
    """
  end
end
