defmodule GenQueueToniq.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :gen_queue_toniq,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    GenQueue adapter for Toniq
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/nsweeting/gen_queue_toniq",
        "GenQueue" => "https://github.com/nsweeting/gen_queue"
      }
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: "https://github.com/nsweeting/gen_queue_toniq"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_queue, "~> 0.1.5"},
      {:exredis, ">= 0.2.4"},
      {:toniq, "~> 1.0", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
