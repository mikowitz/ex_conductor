defmodule ExConductorWeb.LiveHelpers do
  import Phoenix.LiveView

  alias ExConductor.Accounts
  alias Accounts.User

  def assign_instruments(socket) do
    user = socket.assigns.current_user

    if user do
      assign(socket, instruments: user.instruments)
    else
      socket
    end
  end

  def assign_user(socket, session) do
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
