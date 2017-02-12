defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  test "requires user auth for all actions", %{conn: conn} do
    Enum.map([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123"))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  setup %{ conn: conn } = config do
    if username = config[:login_as] do
      user = insert_user(%{username: username})
      conn = assign(build_conn(), :current_user, user)
      { :ok, conn: conn, user: user }
    else
      :ok
    end
  end

  @tag login_as: "foo"
  test "list all users videos on index", %{ conn: conn, user: user } do
    user_video = insert_video(user, title: "funny cats")
    other_video = insert_video(insert_user(%{username: "other"}), title: "whatever")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

end
