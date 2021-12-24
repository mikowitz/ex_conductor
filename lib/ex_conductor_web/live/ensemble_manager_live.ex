defmodule ExConductorWeb.EnsembleManagerLive do
  use ExConductorWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(ensemble_id: generate_ensemble_id())

    {:ok, socket}
  end

  def join_ensemble_link(assigns) do
    link = ExConductorWeb.Endpoint.url() <> "/ensemble_member/" <> assigns.ensemble_id

    ~H"""
    Players can join the ensemble using this link:
    <div>
      <a href={link} id="ensemble-link">
        <%= link %>
      </a>
    </div>
    """
  end

  defp generate_ensemble_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end
end
