defmodule PathExpress do
  import Kernel, except: [get_in: 2]

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

  @doc ~S"""
  Returns a function that accesses all elements of a list that match the provided predicate.

  The returned function is typically passed as an accessor to `get_in/2` and `Kernel.get_in/2`.

  ## Examples
      iex> list = [%{name: "john", salary: 10}, %{name: "francine", salary: 30}]
      iex> get_in(list, [PathExpress.filter(&(&1.salary > 20)), :name])
      ["francine"]

  When no match is found, an empty list is returned:

      iex> list = [%{name: "john", salary: 10}, %{name: "francine", salary: 30}]
      iex> get_in(list, [PathExpress.filter(&(&1.salary >= 50)), :name])
      []

   `nil` or a non-list is traversed by returning an empty list, as if no match is found:

      iex> get_in(nil, [PathExpress.filter(&(&1.salary >= 50)), :name])
      []
      iex> get_in(%{}, [PathExpress.filter(fn a -> a == 10 end)])
      []

   An error is raised if the predicate is not a function or is of the incorrect arity:

      iex> get_in([], [PathExpress.filter(5)])
      ** (FunctionClauseError) no function clause matching in PathExpress.filter/1
  """
  @spec filter((term -> boolean)) :: Kernel.access_fun(data :: list, get_value :: list)
  def filter(func) when is_function(func) do
    fn op, data, next -> filter(op, data, func, next) end
  end

  defp filter(:get, data, func, next) when is_list(data) do
    data |> Enum.filter(func) |> Enum.map(next)
  end

  defp filter(:get, _data, _func, _next) do
    []
  end

  @doc """
  Gets a value from a nested structure.

  Uses a combination of functions from the `Access` module and
  PathExpress to traverse the structures in a nil-safe way
  according to the given `keys`, unless the `key` is a
  function, which is detailed in a later section.

  ## Examples

      iex> users = %{"john" => %{age: 27}, "meg" => %{age: 23}}
      iex> get_in(users, ["john", :age])
      27

  In case any of the keys returns `nil`, `nil` will be returned:

      iex> users = %{"john" => %{age: 27}, "meg" => %{age: 23}}
      iex> get_in(users, ["unknown", :age])
      nil
      iex> get_in(users, ["unknown", PathExpress.at(0)])
      nil

  ## Shortcuts

  Integers in keys will be treated as `PathExpress.at/1` and an
  empty list will be treated as `PathExpress.all/`

      iex> alias PathExpress, as: PE
      iex> data = %{"users" => [%{name: "john", age: 27}, %{name: "meg", age: 23}]}
      iex> PE.get_in(data, ["users", 0, :name])
      "john"
      iex> PE.get_in(data, ["users", [], :age])
      [27, 23]

  The examples above are nil-safe:

      iex> alias PathExpress, as: PE
      iex> data = %{}
      iex> PE.get_in(data, ["users", 0, :name])
      nil
      iex> PE.get_in(data, ["users", [], :age])
      []

  ## Functions as keys

  See documentation for Kernel.get_in/2

  """
  @spec get_in(Access.t(), nonempty_list(term)) :: term
  def get_in(data, keys) do
    Kernel.get_in(data, Enum.map(keys, &key_to_func/1))
  end

  defp key_to_func(k) when is_integer(k), do: at(k)
  defp key_to_func([]), do: all()
  defp key_to_func(k), do: k
end
