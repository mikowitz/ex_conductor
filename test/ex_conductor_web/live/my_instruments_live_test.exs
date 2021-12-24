defmodule ExConductorWeb.MyInstrumentsLiveTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

  import ExConductor.Factory

  test "adding instruments", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, view, _} = live(conn, "/my_instruments")

    view
    |> element("form#add-instrument")
    |> render_submit(%{instrument: "violin"})

    assert has_element?(view, "li[data-instrument=violin]")
    assert has_element?(view, "li[data-instrument=violin] button.remove")
  end

  test "removing instruments", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, view, _} = live(conn, "/my_instruments")

    view
    |> element("form#add-instrument")
    |> render_submit(%{instrument: "violin"})

    assert has_element?(view, "li[data-instrument=violin]")

    view
    |> element("li[data-instrument=violin] button.remove")
    |> render_click()

    refute has_element?(view, "li[data-instrument=violin]")
  end
end
