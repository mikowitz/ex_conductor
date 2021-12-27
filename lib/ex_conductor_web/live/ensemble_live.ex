defmodule ExConductorWeb.EnsembleLive do
  use ExConductorWeb, :live_view

  alias ExConductor.EnsembleRegistry
  alias ExConductorWeb.Endpoint

  import ExConductorWeb.LiveHelpers

  def mount(params, session, socket) do
    socket =
      socket
      |> assign_user(session)
      |> assign_ensemble_id(params["id"])
      |> assign(score_page: nil)

    {:ok, socket}
  end

  def handle_event("select-instrument", %{"instrument" => ""}, socket) do
    EnsembleRegistry.remove_instrument(
      socket.assigns.ensemble_id,
      socket.assigns.current_user.id
    )

    {:noreply, socket}
  end

  def handle_event("select-instrument", %{"instrument" => instrument}, socket) do
    EnsembleRegistry.add_instrument(
      socket.assigns.ensemble_id,
      socket.assigns.current_user.id,
      instrument
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "ensemble_changed"}, socket) do
    {:noreply, socket}
  end

  def handle_info(%{event: "score_page", payload: payload}, socket) do
    socket =
      socket
      |> assign(score_page: payload[:score_page])

    {:noreply, socket}
  end

  defp assign_ensemble_id(socket, id) do
    if EnsembleRegistry.registered?(id) do
      Endpoint.subscribe("ensemble:#{id}")

      socket
      |> assign(:ensemble_id, id)
      |> assign(:bad_ensemble_id, nil)
    else
      socket
      |> assign(:bad_ensemble_id, id)
      |> assign(:ensemble_id, nil)
    end
  end
end
