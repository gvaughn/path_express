# PathExpress

PathExpress is a shortened form of "path expression" also intended to bring
brevity to mind. I first encountered the concept of path expressions as a way
to navigate object-oriented databases. You can also imagine a similarity with XPath,
used to navigate xml documents.

## Rationale

I need to pull values out of json documents from untrusted third parties at the edges
of my system. There's multiple incoming json structures from different sources that
I map to a common Ecto struct for core business logic processing. The initial step
is to navigate paths to fields in the json and save in a map of names known to my
changeset function.

`Kernel.get_in/2` is nil-safe if you are navigating purely a path of maps embedded in
maps, however once you need to navigate steps that deal with lists, then you open
the chance of nil exceptions when keys are missing or are nil instead of an empty list.
For these reasons I developed PathExpress.

## Compatible with `Kernel.get_in/2`

You can use PathExpress as a replacement for the `Access` module functions that operate
on lists in any existing `get_in/2` calls and gain the same nil safety for lists as it
has for maps.

### Example

Before
```elixir
iex> %{"items" => nil} |> get_in(["items", Access.at(0)])
** (RuntimeError) Access.at/1 expected a list, got: nil
   (elixir) lib/access.ex:663: Access.at/4
```

After
```elixir
iex> %{"items" => nil} |> get_in(["items", PathExpress.at(0)])
nil
```

## The "Express" part of the name

If you do this often, you can gain some brevity by letting PathExpress wrap the calls to
`get_in/2` for you. In those cases, there are shortcuts for specifying the path elements
involving lists. An integer retrieves that element of a list, like `PathExpress.at/1` and
an empty list acts as `PathExpress.all/0`. The example above could be expressed as:


```elixir
iex> alias PathExpress, as: PE
iex> %{"items" => nil} |> PE.get_in(["items", 0])
nil
```

In the rare cases (in my experience) that you might want to deal with map keys that are
integers or an empty list, then `Access.key/1` has you covered.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `path_express` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:path_express, "~> 0.1.0"}
  ]
end
```

Docs at [https://hexdocs.pm/path_express](https://hexdocs.pm/path_express).

## TODO

* get_in/3 that takes a default value when path cannot be navigated
* get_in!/2 which assertively raises if any path elements not found (key or list style)
* fetch_in/2 which returns `{:ok, value}` or `:error`
* better CI
* handling of Tuple paths?
* handling up `put_in`, `update_in` `pop_in`, `get_and_update_in` (discussing plans)

