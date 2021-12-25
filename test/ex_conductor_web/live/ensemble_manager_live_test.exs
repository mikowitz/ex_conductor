defmodule ExConductorWeb.EnsembleManagerLiveTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

  import ExConductor.Factory

  @ensemble_id "abcdef12345"

  test "shows correct link", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, _, html} = live(conn, "/ensemble_manager/#{@ensemble_id}")

    assert html =~ "#{ExConductorWeb.Endpoint.url()}/ensemble/#{@ensemble_id}"
  end
end
