defmodule ExConductorWeb.HomeLiveTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

  import ExConductor.Factory

  test "logging in shows option to create ensembles", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, user_view, _} = live(conn, "/home")

    assert has_element?(user_view, "button#start-ensemble")
  end

  test "user with no instruments cannot join an ensemble", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, view, _} = live(conn, "/home")

    refute has_element?(view, "form#join-ensemble")
    assert render(view) =~ ~r/Add an instrument.*to be able to join an ensemble/
  end

  test "starting an ensemble", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, view, _} = live(conn, "/home")

    {:ok, manager_view, _} =
      view
      |> element("button#start-ensemble")
      |> render_click()
      |> follow_redirect(conn)

    assert has_element?(manager_view, "ul#ensemble-members")
    assert has_element?(manager_view, "a#ensemble-link")

    refute has_element?(manager_view, "button#generate-score")
  end
end
