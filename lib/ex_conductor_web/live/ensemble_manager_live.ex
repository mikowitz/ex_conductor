defmodule ExConductorWeb.EnsembleManagerLive do
  use ExConductorWeb, :live_view

  alias ExConductor.EnsembleRegistry
  alias ExConductorWeb.Endpoint

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(ensemble_id: params["id"])
      |> assign(ensemble: %{})

    EnsembleRegistry.register(params["id"])

    Endpoint.subscribe("ensemble:#{socket.assigns.ensemble_id}")

    {:ok, socket}
  end

  def handle_info(%{event: "ensemble_changed", payload: payload}, socket) do
    socket =
      socket
      |> assign(ensemble: payload[:ensemble])

    {:noreply, socket}
  end

  def join_ensemble_link(assigns) do
    link = ExConductorWeb.Endpoint.url() <> "/ensemble/" <> assigns.ensemble_id

    ~H"""
    Players can join the ensemble using this link:
    <div>
      <a href={link} id="ensemble-link">
        <%= link %>
      </a>
    </div>
    """
  end
end
