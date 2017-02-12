defmodule Rumbl.UserTest do
  use  Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs %{name: "User", username: "foo", password: "supersecret"}
  @invalid_attrs %{username: "s"}

  test "a changeset with valid attrs" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "a changeset with invalid attrs" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset does not accept long usernames" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
    assert { :username, "should be at most 20 character(s)" } in errors_on(%User{}, attrs)
  end

  test "password length" do
    attrs = Map.put(@valid_attrs, :password, "a")
    changeset = User.registration_changeset(%User{}, attrs)
    assert { :password, {"should be at least %{count} character(s)", [count: 8, validation: :length, min: 8]} } in changeset.errors
  end

  test "hashes password" do
    attrs = Map.put(@valid_attrs, :password, "supersecret")
    changeset = User.registration_changeset(%User{}, attrs)
    %{password: pass, password_hash: pass_hash} = changeset.changes

    assert changeset.valid?
    assert pass_hash
    assert Comeonin.Bcrypt.checkpw(pass, pass_hash)
  end


end
