defmodule CinderUI.MixProject do
  use Mix.Project

  @source_url "https://github.com/levibuzolic/cinder_ui"
  @version "0.0.1"

  def project do
    [
      app: :cinder_ui,
      version: @version,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      aliases: aliases(),
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls, summary: [threshold: 90]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: ["test.all": :test]
    ]
  end

  defp preferred_cli_env do
    [
      "test.all": :test,
      quality: :test,
      credo: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.github": :test,
      "coveralls.html": :test,
      "coveralls.json": :test,
      "coveralls.lcov": :test,
      "coveralls.cobertura": :test,
      "coveralls.xml": :test
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7 or ~> 1.8"},
      {:phoenix_live_view, "~> 1.0"},
      {:earmark, "~> 1.4", runtime: false},
      {:lucide_icons, "~> 2.0", optional: true},
      {:jason, "~> 1.4", optional: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:floki, ">= 0.35.0", only: :test}
    ]
  end

  defp aliases do
    [
      "test.all": ["test"],
      "docs.with_screenshots": [
        "cmd --cd demo npx playwright test tests/browser/visual.spec.ts",
        "docs"
      ],
      quality: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict",
        "cmd env MIX_ENV=test mix coveralls --raise"
      ]
    ]
  end

  defp description do
    "Shadcn UI Tailwind component library for Phoenix applications."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Levi Buzolic"],
      files: [
        "lib",
        "priv",
        "assets",
        "doc/screenshots",
        "mix.exs",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "dev/lib"]
  defp elixirc_paths(:test), do: ["lib", "dev/lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "readme",
      groups_for_modules: [
        Core: [CinderUI, CinderUI.Classes, CinderUI.Hooks, CinderUI.Icons, CinderUI.JS],
        Components: [
          CinderUI.Components,
          CinderUI.Components.Advanced,
          CinderUI.Components.Actions,
          CinderUI.Components.DataDisplay,
          CinderUI.Components.Feedback,
          CinderUI.Components.Forms,
          CinderUI.Components.Layout,
          CinderUI.Components.Navigation,
          CinderUI.Components.Overlay
        ],
        "Mix Tasks": [Mix.Tasks.CinderUi.Install]
      ]
    ]
  end
end
