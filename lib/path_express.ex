defmodule PathExpress do
  @moduledoc """
  Path Express provides nil-safe list navigation for use with `Kernel.get_in/2`
  plus its own `get_in/2` wrapper with some shortcuts.
  """

  @doc ~S"""
  Returns a function that accesses all the elements in a list.

  The returned function is typically passed as an accessor to `get_in/2` and `Kernel.get_in/2`.

  ## Examples
      iex> list = [%{name: "john"}, %{name: "mary"}]
      iex> get_in(list, [PathExpress.all(), :name])
      ["john", "mary"]
      iex> data = %{items: [%{qty: 1}, %{qty: 2}]}
      iex> get_in(data, [:items, PathExpress.all(), :qty])
      [1, 2]

   `nil` or a non-list is traversed by returning empty list:

       iex> get_in(nil, [PathExpress.all()])
       []
       iex> get_in(%{}, [PathExpress.all()])
       []
  """
  @spec all() :: Kernel.access_fun(data :: list, get_value :: list)
  def all() do
    &all/3
  end

  defp all(:get, data, next) when is_list(data) do
    Enum.map(data, next)
  end

  defp all(:get, _data, _next) do
    []
  end

  # defp all([head | rest], next, gets, updates) do
  #   case next.(head) do
  #     {get, update} -> all(rest, next, [get | gets], [update | updates])
  #     :pop -> all(rest, next, [head | gets], updates)
  #   end
  # end

  # defp all([], _next, gets, updates) do
  #   {:lists.reverse(gets), :lists.reverse(updates)}
  # end

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

  defp at(:get, _data, _index, next) do
    next.(nil)
  end
end
