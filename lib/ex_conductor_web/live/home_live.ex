defmodule ExConductorWeb.HomeLive do
  use ExConductorWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("start-ensemble", _, socket) do
    {:noreply,
     push_redirect(socket, to: Routes.live_path(socket, ExConductorWeb.EnsembleManagerLive))}
  end
end
