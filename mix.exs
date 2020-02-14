defmodule PathExpress.MixProject do
  use Mix.Project

  def project do
    [
      app: :path_express,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  # def application, do: []
end
