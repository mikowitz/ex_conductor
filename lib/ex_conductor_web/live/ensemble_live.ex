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
      |> assign(page_number: nil)

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
      |> assign(page_number: payload[:page_number])

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

  def current_score_page(assigns) do
    img_src = image_data(assigns.src)

    ~H"""
    <img
      id="score"
      src={img_src}
      data-page={@page_number}
      alt="current score page"

    />
    """
  end

  defp image_data(image_src), do: "data:image/png;base64,#{image_src}"
end
