defmodule ExConductorWeb.EnsembleManagerTest do
  use ExConductorWeb.ConnCase

  import Phoenix.LiveViewTest

  import ExConductor.Factory

  @ensemble_id "abcdef12345"

  setup do
    ExConductor.EnsembleRegistry.reset!()

    on_exit(fn ->
      for file <- Path.wildcard("scores/#{@ensemble_id}*") do
        File.rm(file)
      end
    end)
  end

  test "shows correct state for existing ensemble", %{conn: conn} do
    manager = insert(:user)
    manager_conn = log_in_user(conn, manager)

    {:ok, _, _} = live(manager_conn, "/ensemble_manager/#{@ensemble_id}")

    user = insert(:user)
    user_conn = log_in_user(conn, user)

    {:ok, user_view, _} = live(user_conn, "/ensemble/#{@ensemble_id}")

    assert has_element?(user_view, "form#select-instrument")
  end

  test "shows error for non-existent ensemble id", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)

    {:ok, _, html} = live(conn, "/ensemble/#{@ensemble_id}")

    assert html =~ "No existing ensemble found with id <b>#{@ensemble_id}</b>"
  end

  test "selecting an instrument allows the manager to generate a score", %{conn: conn} do
    manager = insert(:user)
    manager_conn = log_in_user(conn, manager)

    {:ok, manager_view, _} = live(manager_conn, "/ensemble_manager/#{@ensemble_id}")

    user = insert(:user_with_violin)
    user_conn = log_in_user(conn, user)
    {:ok, user_view, _} = live(user_conn, "/ensemble/#{@ensemble_id}")

    refute has_element?(manager_view, "button#generate-score")

    user_view
    |> element("form#select-instrument")
    |> render_change(instrument: "violin")

    assert has_element?(manager_view, "button#generate-score")
  end

  test "deselecting the last instrument blocks the manager from generating a score", %{conn: conn} do
    manager = insert(:user)
    manager_conn = log_in_user(conn, manager)

    {:ok, manager_view, _} = live(manager_conn, "/ensemble_manager/#{@ensemble_id}")

    user = insert(:user_with_violin)
    user_conn = log_in_user(conn, user)
    {:ok, user_view, _} = live(user_conn, "/ensemble/#{@ensemble_id}")

    refute has_element?(manager_view, "button#generate-score")

    user_view
    |> element("form#select-instrument")
    |> render_change(instrument: "violin")

    assert has_element?(manager_view, "button#generate-score")

    user_view
    |> element("form#select-instrument")
    |> render_change(instrument: "")

    refute has_element?(manager_view, "button#generate-score")
  end
end
