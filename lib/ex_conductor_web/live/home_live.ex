defmodule ExConductorWeb.HomeLive do
  use ExConductorWeb, :live_view

  alias ExConductor.Accounts
  alias Accounts.User

  import ExConductorWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_user(session)

    {:ok, socket}
  end

  def handle_event("start-ensemble", _, socket) do
    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, ExConductorWeb.EnsembleManagerLive, generate_ensemble_id())
     )}
  end

  def handle_event("join-ensemble", %{"ensemble_id" => ensemble_id}, socket) do
    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, ExConductorWeb.EnsembleLive, ensemble_id)
     )}
  end

  defp generate_ensemble_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end
end
