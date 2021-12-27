defmodule ExConductorWeb.EnsembleManagerLive do
  use ExConductorWeb, :live_view

  alias ExConductor.Score

  alias ExConductor.EnsembleRegistry
  alias ExConductorWeb.Endpoint

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(ensemble_id: params["id"])
      |> assign(ensemble: %{})
      |> assign(score: nil)

    EnsembleRegistry.register(params["id"])

    Endpoint.subscribe("ensemble:#{socket.assigns.ensemble_id}")

    {:ok, socket}
  end

  def handle_event("generate-score", _, socket) do
    send(self(), :generate_score)

    socket =
      socket
      |> put_flash(:info, "Generating score...")

    {:noreply, socket}
  end

  def handle_info(%{event: "ensemble_changed", payload: payload}, socket) do
    socket =
      socket
      |> assign(ensemble: payload[:ensemble])

    {:noreply, socket}
  end

  def handle_info(%{event: "score_page"}, socket) do
    {:noreply, socket}
  end

  def handle_info(:generate_score, socket) do
    score = ExConductor.Score.generate(socket.assigns.ensemble_id, socket.assigns.ensemble)

    socket =
      socket
      |> assign(score: score)
      |> put_flash(:info, "Score generated")

    current_page = Score.current_page(score)

    Endpoint.broadcast!(
      "ensemble:#{socket.assigns.ensemble_id}",
      "score_page",
      score_page: current_page
    )

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
