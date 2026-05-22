defmodule CinderUI.Docs.PreviewRenderer do
  @moduledoc false

  alias CinderUI.Docs.SampleAssets
  alias Phoenix.HTML.Safe

  def render(module, function, code) when is_binary(code) do
    snippet =
      code
      |> String.trim()
      |> String.replace("\r\n", "\n")

    if snippet == "" do
      raise ArgumentError, "empty inline docs example for #{inspect(module)}.#{function}/1"
    end

    preview_snippet = SampleAssets.hydrate_template_for_preview(snippet, module, function)
    unique = System.unique_integer([:positive, :monotonic])
    renderer = Module.concat(__MODULE__, :"DocExample#{unique}")
    file = "docs_example_#{unique}.ex"
    snippet_block = indent_block(preview_snippet, 6)

    source = """
    defmodule #{inspect(renderer)} do
      use Phoenix.Component
      use CinderUI.Components

      # Inline docs previews are rendered outside a Phoenix router context.
      # Treat `~p` examples as path strings so docs snippets can compile.
      defmacro sigil_p({:<<>>, _meta, segments}, _modifiers) do
        quote do
          IO.iodata_to_binary([unquote_splicing(segments)])
        end
      end

      def render(assigns) do
        ~H\"\"\"
    #{snippet_block}
        \"\"\"
      end
    end
    """

    try do
      Code.compile_string(source, file)

      renderer.render(default_snippet_assigns(snippet))
      |> Safe.to_iodata()
      |> IO.iodata_to_binary()
    rescue
      exception ->
        reraise ArgumentError,
                [
                  message:
                    "failed to render inline docs example for #{inspect(module)}.#{function}/1: " <>
                      Exception.message(exception)
                ],
                __STACKTRACE__
    after
      :code.purge(renderer)
      :code.delete(renderer)
    end
  end

  defp indent_block(content, spaces) do
    indentation = String.duplicate(" ", spaces)

    content
    |> String.split("\n")
    |> Enum.map_join("\n", &(indentation <> &1))
  end

  defp default_snippet_assigns(snippet) do
    Regex.scan(~r/@([a-zA-Z_]\w*)/, snippet, capture: :all_but_first)
    |> List.flatten()
    |> Enum.uniq()
    |> Map.new(fn key -> {String.to_atom(key), default_snippet_assign_value(key)} end)
    |> Map.put(:__changed__, %{})
  end

  defp default_snippet_assign_value("form"), do: example_form_assign()
  defp default_snippet_assign_value(_key), do: nil

  defp example_form_assign do
    Phoenix.Component.to_form(
      %{
        "email" => "levi@example.com",
        "quantity" => "3",
        "bio" => "Docs preview copy",
        "active" => "true",
        "terms" => "true",
        "notifications" => "true",
        "role" => "member",
        "owner" => "mira",
        "plan" => "pro",
        "volume" => "42",
        "code" => "482951"
      },
      as: "example"
    )
  end
end
