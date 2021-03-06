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

  def handle_event("clear-score", _, socket) do
    Score.clear!(socket.assigns.score)

    socket =
      socket
      |> assign(score: nil)
      |> put_flash(:info, "Score cleared")

    Endpoint.broadcast!(
      "ensemble:#{socket.assigns.ensemble_id}",
      "score_page",
      score_page: nil,
      page_number: nil
    )

    {:noreply, socket}
  end

  def handle_event("change-page", %{"page" => page_number}, socket) do
    {new_page_number, ""} = Integer.parse(page_number)
    score = Score.set_page(socket.assigns.score, new_page_number)

    socket =
      socket
      |> assign(score: score)

    current_page = Score.current_page(score)

    Endpoint.broadcast!(
      "ensemble:#{socket.assigns.ensemble_id}",
      "score_page",
      score_page: current_page,
      page_number: score.current_page
    )

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
      score_page: current_page,
      page_number: score.current_page
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

  def score_page_preview(assigns) do
    img_src = image_data(assigns.src)
    alt = "Score page #{assigns.page_number}"

    classes =
      [
        "score-preview",
        if(assigns.page_number == assigns.current_page, do: "current", else: nil)
      ]
      |> Enum.reject(&is_nil/1)

    ~H"""
    <img
      class={classes}
      data-page={@page_number}
      src={img_src}
      alt={alt}
      phx-click="change-page"
      phx-value-page={@page_number}
    />
    """
  end

  defp image_data(image_src), do: "data:image/png;base64,#{image_src}"
end
