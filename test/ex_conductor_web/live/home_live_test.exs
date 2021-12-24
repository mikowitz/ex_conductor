defmodule ExConductorWeb.HomeLiveTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

  import ExConductor.Factory

  test "logging in shows options to join and create ensembles", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, user_view, _} = live(conn, "/home")

    assert has_element?(user_view, "button#start-ensemble")
    assert has_element?(user_view, "form#join-ensemble")
  end

  test "starting an ensemble", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, view, _} = live(conn, "/home")

    {:ok, manager_view, _} =
      view
      |> element("button#start-ensemble")
      |> render_click()
      |> follow_redirect(conn, "/ensemble_manager")

    assert has_element?(manager_view, "ul#ensemble-members")
    assert has_element?(manager_view, "a#ensemble-link")

    refute has_element?(manager_view, "button#generate-score")
  end
end
