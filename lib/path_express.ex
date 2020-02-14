defmodule PathExpress do
  @moduledoc """
  Path Express provides nil-safe list navigation for use with `Kernel.get_in/2`
  plus its own `get_in/2` wrapper with some shortcuts.
  """

  @doc ~S"""
  Returns a function that accesses the element at `index` (zero based) of a list.

  The returned function is typically passed as an accessor to `get_in/2` and `Kernel.get_in/2`.

  ## Examples
  #
      iex> list = [%{name: "john"}, %{name: "mary"}]
      iex> get_in(list, [PathExpress.at(1), :name])
      "mary"
      iex> get_in(list, [PathExpress.at(-1), :name])
      "mary"

   `nil` or a non-list is traversed by returning `nil`:

      iex> get_in(nil, [PathExpress.at(0)])
      nil
      iex> get_in(%{}, [PathExpress.at(1)])
      nil
  """
  @spec at(integer) :: Access.access_fun(data :: list, get_value :: term)
  def at(index) when is_integer(index) do
    fn op, data, next -> at(op, data, index, next) end
  end

  defp at(:get, data, index, next) when is_list(data) do
    data |> Enum.at(index) |> next.()
  end

  defp at(_op, _data, _index, next) do
    next.(nil)
  end
end
