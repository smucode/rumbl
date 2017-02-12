defmodule Rumbl.AuthTest do
  require Logger
  alias Rumbl.Auth
  use Rumbl.ConnCase

  setup %{conn: conn} do
    conn = conn
      |> bypass_through(Rumbl.Router, :browser)
      |> get("/")
      {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no user exists", %{conn: conn} do
    conn = conn
      |> Auth.authenticate_user([])
    # Logger.error "****** VALUE: #{inspect(conn)}"
    assert conn.halted
  end

  test "authenticate_user continues when the user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn = conn
      |> Auth.login(%Rumbl.User{ id: 123 })
      |> send_resp(:ok, "")

    next_conn = get login_conn, "/"
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn = conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get logout_conn, "/"
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{ conn: conn } do
    user = insert_user()
    conn = conn
    |> put_session(:user_id, user.id)
    |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{ conn: conn } do
    conn = conn
    |> Auth.call(Repo)

    assert conn.assigns.current_user == nil
  end

  test "login with valid username and pass", %{ conn: conn } do
    user = insert_user(%{username: "foo", password: "supersecret"})
    {:ok, conn} = Auth.login_by_username_and_pass(conn, "foo", "supersecret", repo: Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "login with a 404 user", %{conn: conn} do
    assert {:error, :not_found, _conn} = Auth.login_by_username_and_pass(conn, "123", "234", repo: Repo)
  end

  test "login with username and pass mismatch", %{ conn: conn } do
    _ = insert_user(%{username: "foo", password: "supersecret"})
    assert {:error, :unauthorized, _conn} = Auth.login_by_username_and_pass(conn, "foo", "234", repo: Repo)
  end


end