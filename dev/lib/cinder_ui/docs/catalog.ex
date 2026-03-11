defmodule CinderUI.Docs.Catalog do
  @moduledoc """
  Static documentation catalog used by `mix cinder_ui.docs.build`.

  The catalog renders every public `*/1` component function and returns data
  required to build the static docs site.
  """

  alias CinderUI.Components.Actions
  alias CinderUI.Components.Advanced
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Components.Overlay
  alias CinderUI.Icons
  alias Phoenix.HTML.Safe

  @shadcn_base "https://ui.shadcn.com/docs/components"
  @grouped_shadcn_slugs %{
    "alert" => "alert",
    "avatar" => "avatar",
    "breadcrumb" => "breadcrumb",
    "button" => "button",
    "card" => "card",
    "input" => "input",
    "kbd" => "kbd",
    "pagination" => "pagination",
    "table" => "table",
    "toggle" => "toggle"
  }
  @shadcn_slug_overrides %{
    code_block: nil,
    empty_state: "empty",
    field: "form",
    icon: nil,
    input_otp: "input-otp",
    item: "command",
    menu: "navigation-menu"
  }
  @avatar_levi "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAYGBgYHBgcICAcKCwoLCg8ODAwODxYQERAREBYiFRkVFRkVIh4kHhweJB42KiYmKjY+NDI0PkxERExfWl98fKcBBgYGBgcGBwgIBwoLCgsKDw4MDA4PFhAREBEQFiIVGRUVGRUiHiQeHB4kHjYqJiYqNj40MjQ+TERETF9aX3x8p//CABEIAEAAQAMBIQACEQEDEQH/xAAzAAABBQEBAQAAAAAAAAAAAAAEAgMFBgcAAQgBAAIDAQAAAAAAAAAAAAAAAAADAQIEBf/aAAwDAQACEAMQAAAA3j28eJB5YI4GRwrGBKZM7DMDWNi/niPYQlzw7RqnSxxXS50T7W0nN8zqBV9q4lPR5pbi5efxbSYOZYRswafn8xCu5Ng7Nl6MfpzUqkqaKZW0pBxMluDFfPvVvyQfbBWuB//EADIQAAIBAwMDAwEECwAAAAAAAAECAwAEEQUSIQYxQRMicVEHEBTBFjIzUlVhc4GCk6H/2gAIAQEAAT8AxQo0DSiiOKJFZFGRFGWIFPfQK2FYE/IrqrqqDQtMe6OJGyURU8MQSM1d/az1HLLmO6jt0/p7q0n7Z9egkjW/tILuEkAvH7HApevdEnt4ZbaUujjPIKn4IPY0nWli8jI7Y+jCrLWbS6jVo5lNXHUer3DNJPfSliT5xj+QqfWr+RNpupSvkbjWrXVzPCiyTPhm8nNaBpWlvpcayWiSM3O5gMmtS6Os5VP4S2/DyeCv5irCz1Owu7qOdxgHbx5NS3c0Zzu81F1BNCuYyQaa5TGDUc8ftJxwO1W8cOpW88ZC4Xkk4G0eGHmriwnvLGJbS+aH2DKLwTxQ0nWI9JKWupuZxOCXMndceM1qNxeRzywzPumQgPJjuQooy8cGtzGvUVePT/7WEfHu+RjirCeF7yBI4nZDIY3kHCdskZ81YdRSQ+pbOQHUsqlqjaS2u2v2ZWIG45QouO3B+tXF2bmaWQtkO5bHzWR+7RlCnGBTdBWn8SuB/ildXWdpo00dnb38sszLumDAAKp7Djya0/WI7RLQSoSIm3KAPDAgn55q/tIblvXikJLDgpTi7Sxnae6kIC+xPBxWnXlou1Ln1lTw0QDEfIatN6a0rU4PWtNaMi5ww9MBlP0YHkV+gMJPGqH/AFitX6u1AyywWs7RorFS4OWYjg4PgVNI8rFpHZye5Ylif7mmDAjH0qxnRZYyxK7HDD8xWq6nBOVWJWwqEEkY70mcVp+oTafdR3EbMNv64BxuTyKtwrpuRrhlIBU7icg0SfI+7BrHII7iniKwxy4G2QtjnkbO4oUTXTlzcz6LZFHcFAYs5J/ZnFf/xAAiEQACAgEEAQUAAAAAAAAAAAAAAQIRAwQSIUEgEDFRYXH/2gAIAQIBAT8A8Zyd0iDb4b5KOzUcSZgm3Kn0QraVJIzWsklLpmlSc36NtcmeLl+0aVK5P6QrZKtpO1JSMTXxwKhsfsRVKhPx/8QAIhEAAgIBAwQDAAAAAAAAAAAAAQIAEQQDEiEQIDFBMnKR/9oACAEDAQE/AO1VFWY4A5A64o3TJQKtjwY3mXNBVOkhXgkc/szdyqovoJjPsA+0zW+IvopJM06KFfd3NW+LNmoWI9QCDgiO25iYwvt//9k="
  @avatar_shadcn "data:image/jpeg;base64,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"
  @avatar_mira "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAMDAwMDAwQEBAQFBQUFBQcHBgYHBwsICQgJCAsRCwwLCwwLEQ8SDw4PEg8bFRMTFRsfGhkaHyYiIiYwLTA+PlQBAwMDAwMDBAQEBAUFBQUFBwcGBgcHCwgJCAkICxELDAsLDAsRDxIPDg8SDxsVExMVGx8aGRofJiIiJjAtMD4+VP/CABEIAEAAQAMBEQACEQEDEQH/xAAuAAACAwEBAQEAAAAAAAAAAAAFBgQHCAkCAQMBAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhADEAAAANnhInGZgKayB4KDQRF45pF2GzCeCwwSzNpR4xGtxjIAQPhiYpEXDehbxOP3F05xiuUydIi3h/PYgnMchDAaQL5LRPYpHPImjyNZf5Yh4IZlIQSWGDWQaP/EADUQAAEDAwIDBQYEBwAAAAAAAAIBAwQABREGEgcTIQgiMTJBFBVRYXGBM0JSwTRDRHKSoaL/2gAIAQEAAT8AZYptmm2a4x9oyFoC5LYNO21u9XkP4je4oR4y/oMhRVU64a9pR+/X2DZNX2ZLPJuL3KhymkdWM456NkrogokvpTjNOtU+1TLdA3Wtr8mlNI3e7pjmRopqyi+rpd0E/wAlrQnu2TrWNJmo5Ly6484SplXDRfHr0XJKpLXGU7JNtBQWdgS4psSGz7qKBASEJD1zlK03Ocu+m7RPd88qAw6fzIgRVp1un26ZCvLXaWvhs6Ug2hnqcyYLppnHdYRSH/uuD0Zu32IyAEX2yS4wkpUHu8lMd7cqYRVyqVxMcgOaO1CUpltTbjogSQFE2OYyKAaqu754rRMY4GjdPxXPOzaogl9UbSiTNPhTfhThV2n7iUW82wFLO6ESiP0KuzxL1HCh3V9mWhx35z7/ACXU3t5JeqonpXFLiLeLnPccmPsOw2nkbhQY7a7HNq4Mj6qpqS92tNcUdQ3e3xTd081He5Qc1pXiTb08uMLhasl6YvUPng2bRCSg60XmAk9KexSHhK1Fd3LVbyeaATdIxbbQvLuL1X5JXaE1XLm3xtZcgX1iR3ABUFBTcfj4Vw7v9l0nYYDKmMo7lZ1lzYo5/nIQAHw6CmVqFDvN61Iz7mgk+lubKRHjedAZjqiIRblTKIpJnr1WtLBc41vhHPHlS5cZuSY/JxEX0Va0HJUnLm3uz32jX6qipRlRF0rXrhDYicHqrUlksffH71xwjyyfIcb33XcD8F/SKfer8FrjOFbIbT0YYEGJDkOdB5iMsiqqmF6qqljK1w3lTLPZdaToDTQPSbTyWzNvfgB3Gm3PzSuHOqr1qCy2dy4qJq1aBbE+WgrkD2qmR8Urhwqm7dT9EVkfv1WlWs5GtYNq5pu6bURSCMZj9Q737Vrh11NT2y/u2yRJtduejHhB/G2Oirh9fyilcXEn6h4gA9GsMpqPcGGBaAG1VXnF7iACkgD3lxmtB3DU/DSFrSx3DTpmoQ2lD0wPI6+RD/Mq1pK/3a6WyANxtqW51q1smjCkpEPtBE53s4WuGbChZpMhf6iYap9G0QaIqR1NtSNj4E2aIomiiSL8F6LV7iE5ajgm62y7GlHHVxwdyDhVbyqfDC5rUb/Fi56Q07dlmW3n2m4+zSXAJBRQZXKeImqb9iVrybr+HetZP3G6pbrbcNHo488w4O8E3qOBUURc7fAq0w1bGIj8q1BIKMTTLDJPKpOPkCbNy7uuSWtNw1tFkgwy87TKcz+8upf7Wjd6V//EABQRAQAAAAAAAAAAAAAAAAAAAGD/2gAIAQIBAT8AAf/EABQRAQAAAAAAAAAAAAAAAAAAAGD/2gAIAQMBAT8AAf/Z"

  @sections [
    %{id: "actions", title: "Actions", module: Actions},
    %{id: "forms", title: "Forms", module: Forms},
    %{id: "layout", title: "Layout", module: Layout},
    %{id: "icons", title: "Icons", module: Icons},
    %{id: "feedback", title: "Feedback", module: Feedback},
    %{id: "data-display", title: "Data Display", module: DataDisplay},
    %{id: "navigation", title: "Navigation", module: Navigation},
    %{id: "overlay", title: "Overlay", module: Overlay},
    %{id: "advanced", title: "Advanced", module: Advanced}
  ]
  @component_runtimes %{
    {Forms, :autocomplete} => :progressive,
    {Forms, :input_otp} => :progressive,
    {Forms, :select} => :progressive,
    {Layout, :resizable} => :progressive,
    {DataDisplay, :code_block} => :progressive,
    {Navigation, :navigation_menu} => :scaffold,
    {Overlay, :alert_dialog} => :progressive,
    {Overlay, :dialog} => :progressive,
    {Overlay, :drawer} => :progressive,
    {Overlay, :dropdown_menu} => :progressive,
    {Overlay, :menubar} => :progressive,
    {Overlay, :popover} => :progressive,
    {Overlay, :sheet} => :progressive,
    {Advanced, :calendar} => :scaffold,
    {Advanced, :carousel} => :progressive,
    {Advanced, :chart} => :scaffold,
    {Advanced, :combobox} => :progressive,
    {Advanced, :sidebar} => :scaffold
  }

  @doc """
  Returns catalog sections and pre-rendered component entries.
  """
  @spec sections() :: [map()]
  def sections do
    Enum.map(@sections, &build_section/1)
  end

  @doc """
  Build a single section by id.
  """
  @spec build_section(map()) :: map()
  def build_section(%{module: module} = section) do
    entries =
      module
      |> component_functions()
      |> Enum.map(&entry(module, &1))

    Map.put(section, :entries, entries)
  end

  @doc """
  Returns the section metadata (without entries) for a given module.
  Returns `nil` if no section matches.
  """
  @spec section_for_module(module()) :: map() | nil
  def section_for_module(module) do
    Enum.find(@sections, &(&1.module == module))
  end

  @doc """
  Returns all section definitions (without entries).
  """
  @spec section_definitions() :: [map()]
  def section_definitions, do: @sections

  @doc """
  Total number of component entries in the catalog.
  """
  @spec entry_count() :: non_neg_integer()
  def entry_count do
    sections()
    |> Enum.flat_map(& &1.entries)
    |> length()
  end

  @doc """
  Returns list of all component `{module, function}` pairs.
  """
  @spec functions() :: [{module(), atom()}]
  def functions do
    for section <- @sections,
        function <- component_functions(section.module),
        do: {section.module, function}
  end

  defp component_functions(module) do
    module
    |> Kernel.apply(:__info__, [:functions])
    |> Enum.filter(fn
      {name, 1} -> not String.starts_with?(Atom.to_string(name), "__")
      _ -> false
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  defp entry(module, function) do
    doc = function_doc(module, function)
    inline_doc_examples = inline_doc_examples(doc)
    generated_examples = generated_examples(module, function, inline_doc_examples)
    primary_example = List.first(generated_examples)
    id = "#{module_slug(module)}-#{function}"
    slug = shadcn_slug(function)

    %{
      id: id,
      title: Atom.to_string(function),
      function: function,
      module: module,
      module_name: module |> Module.split() |> List.last(),
      docs: first_paragraph(doc),
      docs_full: doc,
      preview_html: primary_example.preview_html,
      template_heex: primary_example.template_heex,
      preview_align: primary_example.preview_align || :center,
      examples: generated_examples,
      inline_doc_examples: inline_doc_examples,
      attributes: component_attributes(module, function),
      slots: component_slots(module, function),
      source_line: component_line(module, function),
      runtime: component_runtime(module, function),
      shadcn_slug: slug,
      shadcn_url: shadcn_url(slug),
      docs_path: "#{id}/index.html"
    }
  end

  defp module_slug(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end

  defp function_doc(module, function) do
    with {:docs_v1, _, _, _, _, _, docs} <- Code.fetch_docs(module),
         {{:function, ^function, 1}, _, _, %{"en" => doc}, _}
         when is_binary(doc) <- Enum.find(docs, &doc_entry?(&1, function)) do
      String.trim(doc)
    else
      _ -> "No documentation available."
    end
  end

  defp first_paragraph(doc) when is_binary(doc) do
    case doc |> String.split("\n\n") |> List.first() |> String.trim() do
      "" -> "No documentation available."
      paragraph -> paragraph
    end
  end

  defp doc_entry?({{:function, name, 1}, _, _, %{"en" => _}, _}, function), do: name == function
  defp doc_entry?(_, _function), do: false

  defp component_spec(module, function) do
    module
    |> Kernel.apply(:__components__, [])
    |> Map.get(function, %{attrs: [], slots: [], line: nil})
  end

  defp component_line(module, function), do: component_spec(module, function).line

  defp component_attributes(module, function) do
    module
    |> component_spec(function)
    |> Map.get(:attrs, [])
    |> Enum.map(&normalize_attribute/1)
  end

  defp component_slots(module, function) do
    module
    |> component_spec(function)
    |> Map.get(:slots, [])
    |> Enum.map(&normalize_slot/1)
  end

  defp normalize_slot(slot) do
    %{
      name: Atom.to_string(slot.name),
      required: slot.required,
      attrs: slot.attrs |> Enum.map(&normalize_attribute/1)
    }
  end

  defp normalize_attribute(attr) do
    opts = Map.new(attr.opts)
    values = opts |> Map.get(:values, []) |> List.wrap()

    %{
      name: Atom.to_string(attr.name),
      type: inspect(attr.type),
      required: attr.required,
      default: Map.get(opts, :default),
      values: values,
      includes: opts |> Map.get(:include, []) |> List.wrap()
    }
  end

  defp shadcn_slug(function) do
    case Map.fetch(@shadcn_slug_overrides, function) do
      {:ok, slug} ->
        slug

      :error ->
        function
        |> Atom.to_string()
        |> slug_from_name()
    end
  end

  defp component_runtime(module, function) do
    module
    |> then(&Map.get(@component_runtimes, {&1, function}, :server))
    |> runtime_definition()
  end

  defp runtime_definition(:server) do
    %{
      kind: :server,
      label: "Server-rendered",
      summary: "Works with plain server-rendered HEEx and no client hook."
    }
  end

  defp runtime_definition(:progressive) do
    %{
      kind: :progressive,
      label: "Progressive",
      summary: "Server-rendered first, with optional LiveView hooks for richer behavior."
    }
  end

  defp runtime_definition(:scaffold) do
    %{
      kind: :scaffold,
      label: "Scaffold",
      summary: "Provides the styled API shell; application logic or extra JS is still up to you."
    }
  end

  defp slug_from_name(name) do
    case String.split(name, "_", parts: 2) do
      [prefix, _rest] ->
        Map.get(@grouped_shadcn_slugs, prefix, String.replace(name, "_", "-"))

      _ ->
        String.replace(name, "_", "-")
    end
  end

  defp shadcn_url(nil), do: @shadcn_base
  defp shadcn_url(slug), do: "#{@shadcn_base}/#{slug}"

  defp indent_block(content, spaces) do
    indentation = String.duplicate(" ", spaces)

    content
    |> String.split("\n")
    |> Enum.map_join("\n", &(indentation <> &1))
  end

  defp generated_examples(module, function, []) do
    raise ArgumentError,
          "missing inline docs example for #{inspect(module)}.#{function}/1"
  end

  defp generated_examples(module, function, inline_doc_examples) do
    inline_doc_examples
    |> Enum.with_index(1)
    |> Enum.map(fn {example, index} ->
      template_heex =
        example.template_heex
        |> normalize_template_heex()

      display_template_heex = sanitize_template_heex_for_display(template_heex)

      %{
        id: normalize_example_id(example.id, index),
        title: doc_example_title(example.title, function, index),
        description: nil,
        preview_html: render_heex_example(module, function, template_heex),
        template_heex: display_template_heex,
        preview_align: example.preview_align || :center,
        promoted_visual: Map.get(example, :promoted_visual, false)
      }
    end)
  end

  defp normalize_template_heex(template_heex) when is_binary(template_heex) do
    template_heex
    |> String.replace(~r/<\s*CinderUI\.Icons\.icon\b/u, "<.icon")
    |> String.replace(~r/<\/\s*CinderUI\.Icons\.icon\s*>/u, "</.icon>")
  end

  defp sanitize_template_heex_for_display(template_heex) when is_binary(template_heex) do
    template_heex
    |> String.trim()
    |> String.replace(~r/"data:[^"]*"/u, "\"example.png\"")
    |> String.replace(~r/'data:[^']*'/u, "'example.png'")
  end

  defp normalize_example_id(nil, index), do: "example-#{index}"

  defp normalize_example_id(id, index) do
    id
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
    |> case do
      "" -> "example-#{index}"
      value -> value
    end
  end

  defp doc_example_title(nil, function, index),
    do: "#{humanize_function(function)} example #{index}"

  defp doc_example_title(title, function, index) do
    if String.starts_with?(title, "Inline docs example") do
      "#{humanize_function(function)} example #{index}"
    else
      title
    end
  end

  defp humanize_function(function) do
    function
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp render_heex_example(module, function, code) when is_binary(code) do
    snippet =
      code
      |> String.trim()
      |> String.replace("\r\n", "\n")

    if snippet == "" do
      raise ArgumentError, "empty inline docs example for #{inspect(module)}.#{function}/1"
    end

    preview_snippet = hydrate_template_heex_for_preview(snippet, module, function)
    unique = System.unique_integer([:positive, :monotonic])
    renderer = Module.concat(__MODULE__, :"DocExample#{unique}")
    file = "docs_example_#{unique}.ex"
    snippet_block = indent_block(preview_snippet, 6)

    source = """
    defmodule #{inspect(renderer)} do
      use Phoenix.Component
      use CinderUI.Components

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

  defp default_snippet_assigns(snippet) do
    Regex.scan(~r/@([a-zA-Z_]\w*)/, snippet, capture: :all_but_first)
    |> List.flatten()
    |> Enum.uniq()
    |> Map.new(fn key -> {String.to_atom(key), nil} end)
    |> Map.put(:__changed__, %{})
  end

  defp hydrate_template_heex_for_preview(snippet, DataDisplay, :avatar) do
    replace_first_example_image(avatar_sample_data_uri(:levi), snippet)
  end

  defp hydrate_template_heex_for_preview(snippet, DataDisplay, :avatar_group) do
    [:levi, :mira, :ari]
    |> Enum.map(&avatar_sample_data_uri/1)
    |> Enum.reduce(snippet, &replace_first_example_image/2)
  end

  defp hydrate_template_heex_for_preview(snippet, _module, _function), do: snippet

  defp replace_first_example_image(data_uri, snippet) when is_binary(snippet) do
    Regex.replace(
      ~r/src=(["'])example\.png\1/u,
      snippet,
      fn _full, quote -> "src=#{quote}#{data_uri}#{quote}" end,
      global: false
    )
  end

  defp inline_doc_examples(doc) do
    fenced_examples =
      doc
      |> String.trim()
      |> then(&Regex.scan(~r/```([^\n]*)\n(.*?)```/s, &1, capture: :all_but_first))
      |> Enum.map(fn [info, code] ->
        {lang, title, preview_align, promoted_visual} = parse_fence_info(info)
        {lang, title, preview_align, promoted_visual, String.trim(code)}
      end)
      |> Enum.filter(fn {lang, _title, _preview_align, _promoted_visual, code} ->
        code != "" and (lang in ["", "heex", "html", "elixir"] and String.contains?(code, "<."))
      end)

    indented_examples =
      if fenced_examples == [] do
        doc
        |> String.split("\n")
        |> Enum.chunk_by(&String.starts_with?(&1, "    "))
        |> Enum.filter(fn
          [line | _] -> String.starts_with?(line, "    ")
          _ -> false
        end)
        |> Enum.map(fn chunk ->
          chunk
          |> Enum.map_join("\n", &String.trim_leading(&1, "    "))
          |> String.trim()
        end)
        |> Enum.filter(&String.contains?(&1, "<."))
        |> Enum.map(&{"", nil, :center, false, &1})
      else
        []
      end

    (fenced_examples ++ indented_examples)
    |> Enum.uniq()
    |> Enum.with_index(1)
    |> Enum.map(fn {{lang, title, preview_align, promoted_visual, code}, index} ->
      %{
        id: "inline-#{index}",
        title: inline_doc_example_title(title, lang, index),
        template_heex: code,
        preview_align: preview_align,
        promoted_visual: promoted_visual
      }
    end)
  end

  defp parse_fence_info(info) do
    trimmed = String.trim(info)
    title = fence_title(trimmed)
    preview_align = fence_preview_align(trimmed)
    promoted_visual = fence_promoted_visual(trimmed)

    case String.split(trimmed, ~r/\s+/, trim: true) do
      [] ->
        {"", title, preview_align, promoted_visual}

      [lang | rest] ->
        fallback_title =
          case Enum.reject(rest, &String.contains?(&1, "=")) do
            [] -> nil
            tokens -> Enum.join(tokens, " ")
          end

        {String.downcase(lang), title || fallback_title, preview_align, promoted_visual}
    end
  end

  defp fence_title(info) do
    case Regex.run(~r/title\s*=\s*"([^"]+)"/, info, capture: :all_but_first) do
      [title] ->
        title

      _ ->
        case Regex.run(~r/title\s*=\s*'([^']+)'/, info, capture: :all_but_first) do
          [title] -> title
          _ -> nil
        end
    end
  end

  defp fence_preview_align(info) do
    case Regex.run(~r/align\s*=\s*"([^"]+)"/, info, capture: :all_but_first) do
      [value] ->
        normalize_preview_align(value)

      _ ->
        case Regex.run(~r/align\s*=\s*'([^']+)'/, info, capture: :all_but_first) do
          [value] -> normalize_preview_align(value)
          _ -> :center
        end
    end
  end

  defp fence_promoted_visual(info) do
    cond do
      Regex.match?(~r/(?:^|\s)vrt\s*=\s*"true"(?:\s|$)/, info) -> true
      Regex.match?(~r/(?:^|\s)vrt\s*=\s*'true'(?:\s|$)/, info) -> true
      Regex.match?(~r/(?:^|\s)vrt(?:\s|$)/, info) -> true
      true -> false
    end
  end

  defp normalize_preview_align(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      "full" -> :full
      _ -> :center
    end
  end

  defp inline_doc_example_title(nil, "", index), do: "Inline docs example #{index}"
  defp inline_doc_example_title(nil, lang, index), do: "Inline docs example #{index} (#{lang})"
  defp inline_doc_example_title(title, _lang, _index), do: title

  defp avatar_sample_data_uri(:levi), do: @avatar_levi
  defp avatar_sample_data_uri(:ari), do: @avatar_shadcn
  defp avatar_sample_data_uri(:mira), do: @avatar_mira
  defp avatar_sample_data_uri(:noor), do: @avatar_mira
end
