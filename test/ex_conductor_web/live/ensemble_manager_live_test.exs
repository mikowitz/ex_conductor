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

  test "generating a score", %{conn: conn} do
    manager = insert(:user)
    manager_conn = log_in_user(conn, manager)

    {:ok, manager_view, _} = live(manager_conn, "/ensemble_manager/#{@ensemble_id}")

    user = insert(:user_with_violin)
    user_conn = log_in_user(conn, user)
    {:ok, user_view, _} = live(user_conn, "/ensemble/#{@ensemble_id}")

    user_view
    |> element("form#select-instrument")
    |> render_change(instrument: "violin")

    manager_view
    |> element("button#generate-score")
    |> render_click()

    assert render(manager_view) =~ ~r/Score generated/

    assert has_element?(manager_view, "img#score[data-page=1]")
    # assert has_element?(manager_view, "img.score-preview[data-page=1]")
    # assert has_element?(manager_view, "img.score-preview[data-page=2]")

    assert has_element?(user_view, "img#score")
  end
end
