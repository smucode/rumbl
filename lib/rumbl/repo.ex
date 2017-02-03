# defmodule Rumbl.Repo do
#   use Ecto.Repo, otp_app: :rumbl
# end

defmodule Rumbl.Repo do
  @moduledoc """
  In memory repository
  """

  def all(Rumbl.User) do
    [
      %Rumbl.User{ id: "1", name: "Foo Bar", username: "foo", password: "bar" },
      %Rumbl.User{ id: "2", name: "Shiba Inu", username: "doge", password: "wow" }
    ]
  end

  def all(_module), do: []

  def get(module, id) do
    Enum.find all(module), fn map -> map.id == id end
  end

  def get_by(module, params) do
    Enum.find all(module), fn map ->
      Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    end
  end

end