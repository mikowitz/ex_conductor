defmodule ExConductorWeb.MyInstrumentsLive do
  use ExConductorWeb, :live_view

  alias ExConductor.Accounts
  alias Accounts.User

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_user(session)
      |> assign_instruments()
      |> assign(add_instrument_disabled: true)

    {:ok, socket}
  end

  def handle_event("validate-instrument-name", %{"value" => value}, socket) do
    disable_button =
      case value do
        "" -> true
        _ -> false
      end

    {:noreply, assign(socket, add_instrument_disabled: disable_button)}
  end

  def handle_event("add-instrument", %{"instrument" => instrument}, socket) do
    {:ok, user} = Accounts.add_instrument(socket.assigns.current_user, instrument)

    socket =
      assign(socket, current_user: user)
      |> assign_instruments()

    {:noreply, socket}
  end

  def handle_event("remove-instrument", %{"instrument" => instrument}, socket) do
    {:ok, user} = Accounts.remove_instrument(socket.assigns.current_user, instrument)

    socket =
      assign(socket, current_user: user)
      |> assign_instruments()

    {:noreply, socket}
  end

  def instrument_entry(assigns) do
    ~H"""
    <li class="instrument" data-instrument={@instrument}>
      <%= @instrument %>
      <button class="remove" phx-click="remove-instrument" phx-value-instrument={@instrument}>X</button>
    </li>
    """
  end

  def add_instrument(assigns) do
    ~H"""
    <form id="add-instrument" phx-submit="add-instrument">
      <input type="text" name="instrument" autocomplete="off" phx-keyup="validate-instrument-name" />
      <button type="submit" disabled={@button_disabled} phx-disable-with="Adding...">Add Instrument</button>

    </form>
    """
  end

  defp assign_instruments(socket) do
    user = socket.assigns.current_user

    assign(socket, instruments: user.instruments)
  end

  defp assign_user(socket, session) do
    assign(socket, current_user: get_current_user(session))
  end

  defp get_current_user(%{"user_token" => user_token}) do
    case Accounts.get_user_by_session_token(user_token) do
      %User{} = user -> user
      _ -> nil
    end
  end

  defp get_current_user(_), do: nil
end
