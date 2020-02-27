defmodule PathExpress.MixProject do
  use Mix.Project

  def project do
    [
      app: :path_express,
      version: "0.2.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      source_url: "https://github.com/gvaughn/path_express"
    ]
  end

  def application, do: []

  def description() do
    "PathExpress provides increased powers (like nil-safey) from `Kernel.get_in/2` calls"
  end

  def package() do
    [
      maintainers: ["Greg Vaughn"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/gvaughn/path_express"}
    ]
  end

  def docs() do
    [
      main: "readme",
      extras: ["README.md"],
      source_url: "https://github.com/gvaughn/path_express/"
    ]
  end

  def deps() do
    [
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false}
    ]
  end
end
