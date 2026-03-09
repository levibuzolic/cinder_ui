defmodule CinderUI.Docs.Catalog do
  @moduledoc """
  Static documentation catalog used by `mix cinder_ui.docs.build`.

  The catalog renders every public `*/1` component function and returns data
  required to build the static docs site.
  """

  alias CinderUI.Components
  alias CinderUI.Components.Actions
  alias CinderUI.Components.Advanced
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Components.Overlay
  alias CinderUI.Icons
  alias Phoenix.HTML
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

  @doc """
  Returns catalog sections and pre-rendered component entries.
  """
  @spec sections() :: [map()]
  def sections do
    Enum.map(@sections, fn section ->
      entries =
        section.module
        |> component_functions()
        |> Enum.map(&entry(section.module, &1))

      Map.put(section, :entries, entries)
    end)
  end

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

  defp render_component(module, function, assigns) do
    assigns = Map.put_new(assigns, :__changed__, %{})

    module
    |> apply(function, [assigns])
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  rescue
    exception ->
      escaped =
        Exception.format(:error, exception, __STACKTRACE__)
        |> HTML.html_escape()
        |> HTML.safe_to_string()

      "<pre class=\"text-destructive text-xs\">#{escaped}</pre>"
  end

  defp render_template(function, assigns) do
    assigns =
      assigns
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)

    {slot_entries, attr_entries} =
      Enum.split_with(assigns, fn {_key, value} -> slot_assign?(value) end)

    inner_slot =
      Enum.find_value(slot_entries, fn {key, value} -> if key == :inner_block, do: value end)

    named_slots =
      slot_entries
      |> Enum.reject(fn {key, _value} -> key == :inner_block end)
      |> Enum.sort_by(fn {key, _value} -> Atom.to_string(key) end)
      |> Enum.flat_map(fn {name, slot_values} ->
        Enum.map(slot_values, fn slot_value -> render_named_slot(name, slot_value) end)
      end)

    inner_block =
      inner_slot
      |> List.wrap()
      |> Enum.map(&slot_template_body/1)
      |> Enum.reject(&(&1 == ""))

    body = Enum.join(named_slots ++ inner_block, "\n\n")

    attrs =
      attr_entries
      |> Enum.sort_by(fn {key, _value} -> Atom.to_string(key) end)
      |> Enum.map(&render_attr/1)

    open_tag =
      case attrs do
        [] ->
          "<.#{function}"

        _ ->
          "<.#{function}\n" <> Enum.map_join(attrs, "\n", &"  #{&1}")
      end

    if body == "" do
      open_tag <> " />"
    else
      open_tag <> ">\n" <> indent_block(body, 2) <> "\n</.#{function}>"
    end
  end

  defp render_named_slot(name, slot_value) do
    attrs =
      slot_value
      |> Map.delete(:inner_block)
      |> Map.delete(:template)
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Enum.sort_by(fn {key, _value} -> Atom.to_string(key) end)
      |> Enum.map(&render_attr/1)

    open_tag =
      case attrs do
        [] -> "<:#{name}>"
        _ -> "<:#{name} " <> Enum.join(attrs, " ") <> ">"
      end

    content = slot_template_body(slot_value)

    if content == "" do
      open_tag <> "</:#{name}>"
    else
      open_tag <> "\n" <> indent_block(content, 2) <> "\n</:#{name}>"
    end
  end

  defp render_attr({key, value}) do
    key = Atom.to_string(key)

    case value do
      value when is_binary(value) ->
        ~s(#{key}=#{inspect(value)})

      value when is_boolean(value) ->
        ~s(#{key}={#{value}})

      value when is_integer(value) or is_float(value) ->
        ~s(#{key}={#{value}})

      value when is_atom(value) ->
        ~s(#{key}={#{inspect(value)}})

      value when is_list(value) or is_map(value) ->
        ~s(#{key}={#{inspect(value, pretty: true, limit: :infinity)}})

      value ->
        ~s(#{key}={#{inspect(value)}})
    end
  end

  defp slot_assign?(value) do
    is_list(value) and value != [] and
      Enum.all?(value, fn
        %{inner_block: inner_block} when is_function(inner_block, 2) -> true
        _ -> false
      end)
  end

  defp slot_body(%{inner_block: inner_block}) do
    inner_block
    |> Kernel.apply([%{}, nil])
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> String.trim()
  rescue
    _ -> ""
  end

  defp slot_template_body(%{template: template}) when is_binary(template),
    do: String.trim(template)

  defp slot_template_body(slot_value), do: slot_body(slot_value)

  defp indent_block(content, spaces) do
    indentation = String.duplicate(" ", spaces)

    content
    |> String.split("\n")
    |> Enum.map_join("\n", &(indentation <> &1))
  end

  defp generated_examples(module, function, inline_doc_examples) do
    if inline_doc_examples != [] do
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
          preview_align: example.preview_align || :center
        }
      end)
    else
      module
      |> sample_examples(function)
      |> Enum.with_index(1)
      |> Enum.map(fn {example, index} ->
        assigns = example.assigns

        template_heex =
          function
          |> render_template(assigns)
          |> normalize_template_heex()

        display_template_heex = sanitize_template_heex_for_display(template_heex)

        %{
          id: normalize_example_id(example[:id], index),
          title: example[:title] || default_example_title(index),
          description: example[:description],
          preview_html: render_component(module, function, assigns),
          template_heex: display_template_heex,
          preview_align: :center
        }
      end)
    end
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

  defp default_example_title(1), do: "Default"
  defp default_example_title(index), do: "Example #{index}"

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

    preview_snippet = hydrate_template_heex_for_preview(snippet, module, function)

    cond do
      snippet == "" ->
        render_component(module, function, sample_assigns(module, function))

      true ->
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
          _ ->
            render_component(module, function, sample_assigns(module, function))
        after
          :code.purge(renderer)
          :code.delete(renderer)
        end
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
        {lang, title, preview_align} = parse_fence_info(info)
        {lang, title, preview_align, String.trim(code)}
      end)
      |> Enum.filter(fn {lang, _title, _preview_align, code} ->
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
        |> Enum.map(&{"", nil, :center, &1})
      else
        []
      end

    (fenced_examples ++ indented_examples)
    |> Enum.uniq()
    |> Enum.with_index(1)
    |> Enum.map(fn {{lang, title, preview_align, code}, index} ->
      %{
        id: "inline-#{index}",
        title: inline_doc_example_title(title, lang, index),
        template_heex: code,
        preview_align: preview_align
      }
    end)
  end

  defp parse_fence_info(info) do
    trimmed = String.trim(info)
    title = fence_title(trimmed)
    preview_align = fence_preview_align(trimmed)

    case String.split(trimmed, ~r/\s+/, trim: true) do
      [] ->
        {"", title, preview_align}

      [lang | rest] ->
        fallback_title =
          case Enum.reject(rest, &String.contains?(&1, "=")) do
            [] -> nil
            tokens -> Enum.join(tokens, " ")
          end

        {String.downcase(lang), title || fallback_title, preview_align}
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

  defp normalize_preview_align(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      "full" -> :full
      _ -> :center
    end
  end

  defp inline_doc_example_title(nil, "", index), do: "Inline docs example #{index}"
  defp inline_doc_example_title(nil, lang, index), do: "Inline docs example #{index} (#{lang})"
  defp inline_doc_example_title(title, _lang, _index), do: title

  defp sample_examples(Actions, :button) do
    [
      %{
        id: "primary",
        title: "Primary CTA",
        description: "Default shadcn call-to-action button",
        assigns: %{inner_block: slot("Create project")}
      },
      %{
        id: "destructive-loading",
        title: "Destructive Loading",
        description: "Destructive action with loading spinner",
        assigns: %{variant: :destructive, loading: true, inner_block: slot("Deleting...")}
      }
    ]
  end

  defp sample_examples(Forms, :field) do
    [
      %{
        id: "profile",
        title: "Profile Field",
        description: "Label, helper text, and input control",
        assigns: sample_assigns(Forms, :field)
      },
      %{
        id: "validation",
        title: "Validation State",
        description: "Field with inline validation error",
        assigns: field_validation_assigns()
      }
    ]
  end

  defp sample_examples(Feedback, :alert) do
    [
      %{
        id: "notice",
        title: "Notice Alert",
        description: "Default informational alert",
        assigns: sample_assigns(Feedback, :alert)
      },
      %{
        id: "destructive",
        title: "Destructive Alert",
        description: "Irreversible action warning style",
        assigns: destructive_alert_assigns()
      }
    ]
  end

  defp sample_examples(DataDisplay, :accordion) do
    [
      %{
        id: "faq",
        title: "FAQ Accordion",
        description: "Common questions with expanded first section",
        assigns: sample_assigns(DataDisplay, :accordion)
      },
      %{
        id: "release-notes",
        title: "Release Notes",
        description: "Changelog-focused accordion structure",
        assigns: release_notes_accordion_assigns()
      }
    ]
  end

  defp sample_examples(Navigation, :tabs) do
    [
      %{
        id: "default",
        title: "Default Tabs",
        description: "Segmented tab controls with content panels",
        assigns: sample_assigns(Navigation, :tabs)
      },
      %{
        id: "line",
        title: "Line Variant",
        description: "Line-style tabs for settings surfaces",
        assigns: line_tabs_assigns()
      }
    ]
  end

  defp sample_examples(Overlay, :dialog) do
    [
      %{
        id: "settings",
        title: "Settings Dialog",
        description: "Standard dialog with trigger, copy, and footer actions",
        assigns: sample_assigns(Overlay, :dialog)
      },
      %{
        id: "confirmation",
        title: "Confirmation Dialog",
        description: "Confirmation flow with cancel and destructive actions",
        assigns: destructive_dialog_assigns()
      }
    ]
  end

  defp sample_examples(Advanced, :command) do
    [
      %{
        id: "palette",
        title: "Command Palette",
        description: "Grouped quick actions and navigation items",
        assigns: command_palette_assigns()
      },
      %{
        id: "project-switcher",
        title: "Project Switcher",
        description: "Cross-project jump menu with grouped items",
        assigns: project_switcher_command_assigns()
      }
    ]
  end

  defp sample_examples(Layout, :card) do
    [
      %{
        id: "profile",
        title: "Profile Card",
        description: "Header, metadata, and footer actions",
        assigns: card_profile_assigns()
      },
      %{
        id: "pricing",
        title: "Pricing Card",
        description: "Pricing details with primary CTA",
        assigns: card_pricing_assigns()
      }
    ]
  end

  defp sample_examples(module, function) do
    [%{id: "default", title: "Default", assigns: sample_assigns(module, function)}]
  end

  defp card_profile_assigns do
    badge_html =
      render_component(Feedback, :badge, %{variant: :secondary, inner_block: slot("Active")})

    title_html = render_component(Layout, :card_title, %{inner_block: slot("Philip J. Fry")})

    description_html =
      render_component(Layout, :card_description, %{inner_block: slot("Senior Engineer · Sydney")})

    action_html =
      render_component(Layout, :card_action, %{
        inner_block:
          slot(
            badge_html,
            """
            <.badge variant={:secondary}>Active</.badge>
            """
          )
      })

    header_html =
      render_component(Layout, :card_header, %{
        inner_block:
          slot(
            title_html <> "\n" <> description_html <> "\n" <> action_html,
            """
            <.card_title>Philip J. Fry</.card_title>
            <.card_description>Senior Engineer · Sydney</.card_description>
            <.card_action>
              <.badge variant={:secondary}>Active</.badge>
            </.card_action>
            """
          )
      })

    content_html =
      render_component(Layout, :card_content, %{
        inner_block:
          slot(
            "<p class=\"text-sm text-muted-foreground\">Maintains docs tooling, component APIs, and release workflows.</p>",
            "<p class=\"text-sm text-muted-foreground\">Maintains docs tooling, component APIs, and release workflows.</p>"
          )
      })

    primary_action_html =
      render_component(Actions, :button, %{size: :sm, inner_block: slot("Message")})

    secondary_action_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("View Profile")
      })

    footer_html =
      render_component(Layout, :card_footer, %{
        inner_block:
          slot(
            primary_action_html <> "\n" <> secondary_action_html,
            """
            <.button size={:sm}>Message</.button>
            <.button variant={:outline} size={:sm}>View Profile</.button>
            """
          )
      })

    %{
      inner_block:
        slot(
          header_html <> "\n" <> content_html <> "\n" <> footer_html,
          """
          <.card_header>
            <.card_title>Philip J. Fry</.card_title>
            <.card_description>Senior Engineer · Sydney</.card_description>
            <.card_action>
              <.badge variant={:secondary}>Active</.badge>
            </.card_action>
          </.card_header>
          <.card_content>
            <p class="text-sm text-muted-foreground">
              Maintains docs tooling, component APIs, and release workflows.
            </p>
          </.card_content>
          <.card_footer>
            <.button size={:sm}>Message</.button>
            <.button variant={:outline} size={:sm}>View Profile</.button>
          </.card_footer>
          """
        )
    }
  end

  defp card_pricing_assigns do
    title_html = render_component(Layout, :card_title, %{inner_block: slot("Pro Plan")})

    description_html =
      render_component(Layout, :card_description, %{
        inner_block: slot("Best for production teams shipping weekly.")
      })

    header_html =
      render_component(Layout, :card_header, %{
        inner_block:
          slot(
            title_html <> "\n" <> description_html,
            """
            <.card_title>Pro Plan</.card_title>
            <.card_description>Best for production teams shipping weekly.</.card_description>
            """
          )
      })

    content_html =
      render_component(Layout, :card_content, %{
        inner_block:
          slot(
            """
            <p class=\"text-2xl font-semibold\">$49<span class=\"text-sm font-normal text-muted-foreground\">/month</span></p>
            <ul class=\"mt-2 list-disc space-y-1 pl-4 text-sm text-muted-foreground\">
              <li>Unlimited projects</li>
              <li>Priority support</li>
              <li>Team analytics</li>
            </ul>
            """,
            """
            <p class="text-2xl font-semibold">$49<span class="text-sm font-normal text-muted-foreground">/month</span></p>
            <ul class="mt-2 list-disc space-y-1 pl-4 text-sm text-muted-foreground">
              <li>Unlimited projects</li>
              <li>Priority support</li>
              <li>Team analytics</li>
            </ul>
            """
          )
      })

    cta_html =
      render_component(Actions, :button, %{
        class: "w-full",
        inner_block: slot("Start 14-day trial")
      })

    footer_html =
      render_component(Layout, :card_footer, %{
        inner_block:
          slot(
            cta_html,
            """
            <.button class="w-full">Start 14-day trial</.button>
            """
          )
      })

    %{
      inner_block:
        slot(
          header_html <> "\n" <> content_html <> "\n" <> footer_html,
          """
          <.card_header>
            <.card_title>Pro Plan</.card_title>
            <.card_description>Best for production teams shipping weekly.</.card_description>
          </.card_header>
          <.card_content>
            <p class="text-2xl font-semibold">$49<span class="text-sm font-normal text-muted-foreground">/month</span></p>
            <ul class="mt-2 list-disc space-y-1 pl-4 text-sm text-muted-foreground">
              <li>Unlimited projects</li>
              <li>Priority support</li>
              <li>Team analytics</li>
            </ul>
          </.card_content>
          <.card_footer>
            <.button class="w-full">Start 14-day trial</.button>
          </.card_footer>
          """
        )
    }
  end

  defp field_validation_assigns do
    label_html =
      render_component(Forms, :label, %{
        for: "docs-password",
        inner_block: slot("Password")
      })

    input_html =
      render_component(Forms, :input, %{
        id: "docs-password",
        type: "password",
        value: "short"
      })

    %{
      label:
        slot(
          label_html,
          """
          <.label for="docs-password">Password</.label>
          """
        ),
      description: slot("Use at least 12 characters."),
      error: slot("Password must include at least one symbol."),
      inner_block:
        slot(
          input_html,
          """
          <.input id="docs-password" type="password" value="short" />
          """
        )
    }
  end

  defp destructive_alert_assigns do
    icon_html = render_component(Icons, :icon, %{name: "triangle-alert", class: "size-4"})

    title_html = render_component(Feedback, :alert_title, %{inner_block: slot("Deploy blocked")})

    description_html =
      render_component(Feedback, :alert_description, %{
        inner_block: slot("Production checks failed. Resolve blockers before redeploying.")
      })

    %{
      variant: :destructive,
      inner_block:
        slot(
          """
          #{icon_html}
          #{title_html}
          #{description_html}
          """,
          """
          <.icon name="triangle-alert" class="size-4" />
          <.alert_title>Deploy blocked</.alert_title>
          <.alert_description>
            Production checks failed. Resolve blockers before redeploying.
          </.alert_description>
          """
        )
    }
  end

  defp release_notes_accordion_assigns do
    %{
      item: [
        %{
          title: "v0.4.0 · New components",
          open: true,
          inner_block: fn _, _ -> "Added pagination, tabs, and command palette docs pages." end
        },
        %{
          title: "v0.3.2 · Docs quality",
          inner_block: fn _, _ -> "Added generated attr/slot tables and HEEx copy snippets." end
        },
        %{
          title: "v0.3.0 · Static site",
          inner_block: fn _, _ -> "Introduced static docs export and theme controls." end
        }
      ]
    }
  end

  defp line_tabs_assigns do
    %{
      value: "profile",
      variant: :line,
      trigger: [
        %{value: "profile", inner_block: fn _, _ -> "Profile" end},
        %{value: "security", inner_block: fn _, _ -> "Security" end},
        %{value: "billing", inner_block: fn _, _ -> "Billing" end}
      ],
      content: [
        %{value: "profile", inner_block: fn _, _ -> "Update your profile preferences." end},
        %{value: "security", inner_block: fn _, _ -> "Manage MFA, passkeys, and sessions." end},
        %{value: "billing", inner_block: fn _, _ -> "Control plan and payment settings." end}
      ]
    }
  end

  defp destructive_dialog_assigns do
    trigger_html =
      render_component(Actions, :button, %{
        variant: :outline,
        inner_block: slot("Delete project")
      })

    cancel_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Cancel")
      })

    delete_html =
      render_component(Actions, :button, %{
        variant: :destructive,
        size: :sm,
        inner_block: slot("Delete")
      })

    %{
      id: "docs-dialog-destructive",
      open: false,
      trigger:
        slot(
          trigger_html,
          """
          <.button variant={:outline}>Delete project</.button>
          """
        ),
      title: slot("Delete project?"),
      description: slot("This action permanently removes deployments and analytics."),
      inner_block:
        slot(
          "<p class=\"text-sm text-muted-foreground\">Type the project name to confirm deletion.</p>",
          "<p class=\"text-sm text-muted-foreground\">Type the project name to confirm deletion.</p>"
        ),
      footer:
        slot(
          cancel_html <> "\n" <> delete_html,
          """
          <.button variant={:outline} size={:sm}>Cancel</.button>
          <.button variant={:destructive} size={:sm}>Delete</.button>
          """
        )
    }
  end

  defp project_switcher_command_assigns do
    docs_item_html =
      render_component(Advanced, :item, %{value: "docs", inner_block: slot("Docs site")})

    demo_item_html =
      render_component(Advanced, :item, %{value: "demo", inner_block: slot("Demo app")})

    platform_item_html =
      render_component(Advanced, :item, %{value: "platform", inner_block: slot("Platform team")})

    %{
      placeholder: "Jump to project...",
      group: [
        %{
          heading: "Projects",
          inner_block: fn _, _ -> HTML.raw(docs_item_html <> "\n" <> demo_item_html) end,
          template: """
          <.item value="docs">Docs site</.item>
          <.item value="demo">Demo app</.item>
          """
        },
        %{
          heading: "Teams",
          inner_block: fn _, _ -> HTML.raw(platform_item_html) end,
          template: """
          <.item value="platform">Platform team</.item>
          """
        }
      ]
    }
  end

  defp command_palette_assigns do
    profile_item_html =
      render_component(Advanced, :item, %{value: "profile", inner_block: slot("Profile")})

    billing_item_html =
      render_component(Advanced, :item, %{value: "billing", inner_block: slot("Billing")})

    settings_item_html =
      render_component(Advanced, :item, %{value: "settings", inner_block: slot("Settings")})

    %{
      placeholder: "Search commands...",
      group: [
        %{
          heading: "General",
          inner_block: fn _, _ -> HTML.raw(profile_item_html <> "\n" <> billing_item_html) end,
          template: """
          <.item value="profile">Profile</.item>
          <.item value="billing">Billing</.item>
          """
        },
        %{
          heading: "Workspace",
          inner_block: fn _, _ -> HTML.raw(settings_item_html) end,
          template: """
          <.item value="settings">Settings</.item>
          """
        }
      ]
    }
  end

  defp sample_assigns(Actions, :button) do
    %{inner_block: slot("Button")}
  end

  defp sample_assigns(Actions, :button_group) do
    left_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Left")
      })

    right_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Right")
      })

    %{
      inner_block:
        slot(
          left_button_html <> "\n" <> right_button_html,
          """
          <.button variant={:outline} size={:sm}>Left</.button>
          <.button variant={:outline} size={:sm}>Right</.button>
          """
        )
    }
  end

  defp sample_assigns(Actions, :toggle) do
    %{pressed: true, inner_block: slot("Bold")}
  end

  defp sample_assigns(Actions, :toggle_group) do
    toggle_a_html =
      render_component(Actions, :toggle, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("A")
      })

    toggle_b_html =
      render_component(Actions, :toggle, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("B")
      })

    %{
      inner_block:
        slot(
          toggle_a_html <> "\n" <> toggle_b_html,
          """
          <.toggle variant={:outline} size={:sm}>A</.toggle>
          <.toggle variant={:outline} size={:sm}>B</.toggle>
          """
        )
    }
  end

  defp sample_assigns(Forms, :checkbox),
    do: %{id: "docs-checkbox", checked: true, inner_block: slot("Accept terms")}

  defp sample_assigns(Forms, :field_control) do
    %{
      inner_block: slot(~S(<.input id="docs-field-control" value="levi" />))
    }
  end

  defp sample_assigns(Forms, :field_description),
    do: %{inner_block: slot("Helper copy appears here.")}

  defp sample_assigns(Forms, :field_message),
    do: %{inner_block: slot("Changes save automatically.")}

  defp sample_assigns(Forms, :field_error),
    do: %{inner_block: slot("This value is required.")}

  defp sample_assigns(Forms, :field_label),
    do: %{inner_block: slot(~S(<.label for="docs-field-input">Username</.label>))}

  defp sample_assigns(Forms, :field) do
    label_html =
      render_component(Forms, :label, %{for: "docs-field-input", inner_block: slot("Username")})

    input_html = render_component(Forms, :input, %{id: "docs-field-input", value: "levi"})

    %{
      label:
        slot(
          label_html,
          """
          <.label for="docs-field-input">Username</.label>
          """
        ),
      description: slot("This is your public identifier."),
      message: slot("Visible immediately after save."),
      error: slot(""),
      inner_block:
        slot(
          input_html,
          ~S(<.input id="docs-field-input" value="levi" />)
        )
    }
  end

  defp sample_assigns(Forms, :input),
    do: %{id: "docs-input", placeholder: "name@example.com", type: "email"}

  defp sample_assigns(Forms, :autocomplete) do
    %{
      id: "docs-autocomplete",
      name: "owner",
      value: "levi",
      loading_text: "Searching teammates...",
      option: [
        %{value: "levi", label: "Levi Buzolic", description: "Engineering"},
        %{value: "mira", label: "Mira Chen", description: "Design"},
        %{value: "sam", label: "Sam Hall", description: "Operations"}
      ],
      empty: [slot("No matching teammates.")]
    }
  end

  defp sample_assigns(Forms, :input_group) do
    search_input_html = render_component(Forms, :input, %{value: "search"})

    go_button_html =
      render_component(Actions, :button, %{variant: :ghost, size: :xs, inner_block: slot("Go")})

    %{
      inner_block:
        slot(
          search_input_html <> "\n" <> go_button_html,
          """
          <.input value="search" />
          <.button variant={:ghost} size={:xs}>Go</.button>
          """
        )
    }
  end

  defp sample_assigns(Forms, :input_otp),
    do: %{name: "code[]", values: ["1", "2", "", "", "", ""]}

  defp sample_assigns(Forms, :label), do: %{for: "docs-input", inner_block: slot("Email")}

  defp sample_assigns(Forms, :radio_group) do
    %{
      name: "team-size",
      value: "small",
      option: [
        %{value: "solo", label: "Solo"},
        %{value: "small", label: "Small"}
      ]
    }
  end

  defp sample_assigns(Forms, :native_select) do
    %{
      name: "native-plan",
      value: "pro",
      option: [
        %{value: "free", label: "Free"},
        %{value: "pro", label: "Pro"}
      ]
    }
  end

  defp sample_assigns(Forms, :select) do
    %{
      id: "docs-select",
      name: "plan",
      value: "pro",
      clearable: true,
      option: [
        %{value: "free", label: "Free", description: "For side projects", group: "Plans"},
        %{value: "pro", label: "Pro", description: "For growing teams", group: "Plans"}
      ]
    }
  end

  defp sample_assigns(Forms, :slider), do: %{id: "docs-slider", value: 65}

  defp sample_assigns(Forms, :switch),
    do: %{id: "docs-switch", checked: true, inner_block: slot("Enabled")}

  defp sample_assigns(Forms, :textarea), do: %{id: "docs-textarea", value: "Textarea value"}

  defp sample_assigns(Layout, :aspect_ratio) do
    %{
      ratio: "16 / 9",
      inner_block:
        slot(
          "<div class=\"flex h-full w-full items-center justify-center bg-muted text-xs text-muted-foreground\">16:9</div>"
        )
    }
  end

  defp sample_assigns(Layout, :card) do
    card_profile_assigns()
  end

  defp sample_assigns(Layout, :card_action), do: %{inner_block: slot("Action")}
  defp sample_assigns(Layout, :card_content), do: %{inner_block: slot("Card content")}
  defp sample_assigns(Layout, :card_description), do: %{inner_block: slot("Card description")}
  defp sample_assigns(Layout, :card_footer), do: %{inner_block: slot("Card footer")}
  defp sample_assigns(Layout, :card_header), do: %{inner_block: slot("Card header")}
  defp sample_assigns(Layout, :card_title), do: %{inner_block: slot("Card title")}
  defp sample_assigns(Layout, :kbd), do: %{inner_block: slot("⌘K")}

  defp sample_assigns(Layout, :kbd_group),
    do: %{inner_block: slot("<span>⌘</span><span>K</span>")}

  defp sample_assigns(Layout, :resizable) do
    %{
      direction: :horizontal,
      panel: [
        %{
          size: 35,
          inner_block: fn _, _ ->
            HTML.raw("<div class=\"rounded-md bg-muted p-2 text-xs\">Panel A</div>")
          end,
          template: "<div class=\"rounded-md bg-muted p-2 text-xs\">Panel A</div>"
        },
        %{
          size: 65,
          inner_block: fn _, _ ->
            HTML.raw("<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Panel B</div>")
          end,
          template: "<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Panel B</div>"
        }
      ]
    }
  end

  defp sample_assigns(Layout, :scroll_area),
    do: %{
      class: "h-20 rounded-md border",
      inner_block:
        slot(
          Enum.map_join(1..8, "", fn index ->
            ~s(<div class="py-1 text-sm">Scrollable content #{index}</div>)
          end),
          Enum.map_join(1..8, "\n", fn index ->
            ~s(<div class="py-1 text-sm">Scrollable content #{index}</div>)
          end)
        )
    }

  defp sample_assigns(Layout, :separator), do: %{orientation: :horizontal}
  defp sample_assigns(Layout, :skeleton), do: %{class: "h-4 w-40"}
  defp sample_assigns(Icons, :icon), do: %{name: "circle-alert", class: "size-4"}

  defp sample_assigns(Feedback, :alert) do
    icon_html = render_component(Icons, :icon, %{name: "circle-alert", class: "size-4"})

    %{
      inner_block:
        slot(
          """
          #{icon_html}
          <div data-slot=\"alert-title\" class=\"font-medium\">Notice</div>
          <div data-slot=\"alert-description\" class=\"text-sm\">Build completed.</div>
          """,
          """
          <.icon name="circle-alert" class="size-4" />
          <.alert_title>Notice</.alert_title>
          <.alert_description>Build completed.</.alert_description>
          """
        )
    }
  end

  defp sample_assigns(Feedback, :alert_description), do: %{inner_block: slot("Description text")}
  defp sample_assigns(Feedback, :alert_title), do: %{inner_block: slot("Alert title")}
  defp sample_assigns(Feedback, :badge), do: %{variant: :secondary, inner_block: slot("Beta")}
  defp sample_assigns(Feedback, :flash), do: %{kind: :info, flash: %{"info" => "Settings saved"}}

  defp sample_assigns(Feedback, :flash_group) do
    %{
      id: "flash-group-preview",
      flash: %{"info" => "Saved", "error" => "Unable to complete request"}
    }
  end

  defp sample_assigns(Feedback, :empty_state) do
    reset_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Reset")
      })

    %{
      title: slot("No results"),
      description: slot("Try a different filter."),
      action:
        slot(
          reset_html,
          "<.button variant={:outline} size={:sm}>Reset</.button>"
        ),
      icon: slot("<span class=\"text-xl\">◌</span>")
    }
  end

  defp sample_assigns(Feedback, :progress), do: %{value: 72}
  defp sample_assigns(Feedback, :spinner), do: %{}

  defp sample_assigns(DataDisplay, :accordion) do
    %{
      item: [
        %{title: "What is this?", open: true, inner_block: fn _, _ -> "A static preview." end},
        %{
          title: "Is it interactive?",
          inner_block: fn _, _ -> "Some components are progressively enhanced." end
        }
      ]
    }
  end

  defp sample_assigns(DataDisplay, :avatar) do
    %{src: avatar_sample_data_uri(:levi), alt: "Levi"}
  end

  defp sample_assigns(DataDisplay, :avatar_group) do
    preview_html =
      [
        render_component(DataDisplay, :avatar, %{
          src: avatar_sample_data_uri(:levi),
          alt: "Levi"
        }),
        render_component(DataDisplay, :avatar, %{
          src: avatar_sample_data_uri(:ari),
          alt: "Shadcn"
        }),
        render_component(DataDisplay, :avatar, %{
          src: avatar_sample_data_uri(:noor),
          alt: "Mira"
        }),
        render_component(DataDisplay, :avatar_group_count, %{inner_block: slot("+2")})
      ]
      |> Enum.join("\n")

    %{
      inner_block:
        slot(
          preview_html,
          """
          <.avatar src="#{avatar_sample_data_uri(:levi)}" alt="Levi" />
          <.avatar src="#{avatar_sample_data_uri(:noor)}" alt="Mira" />
          <.avatar src="#{avatar_sample_data_uri(:ari)}" alt="Shadcn" />
          <.avatar_group_count>+2</.avatar_group_count>
          """
        )
    }
  end

  defp sample_assigns(DataDisplay, :avatar_group_count), do: %{inner_block: slot("+3")}

  defp sample_assigns(DataDisplay, :code_block),
    do: %{inner_block: slot("mix cinder_ui.docs.build")}

  defp sample_assigns(DataDisplay, :collapsible) do
    %{open: true, trigger: slot("Toggle details"), inner_block: slot("Expanded content")}
  end

  defp sample_assigns(DataDisplay, :table) do
    %{
      inner_block:
        slot(
          """
          <caption data-slot=\"table-caption\">Deployment status</caption>
          <thead data-slot=\"table-header\">
            <tr data-slot=\"table-row\">
              <th data-slot=\"table-head\">Service</th>
              <th data-slot=\"table-head\">Owner</th>
              <th data-slot=\"table-head\">Status</th>
            </tr>
          </thead>
          <tbody data-slot=\"table-body\">
            <tr data-slot=\"table-row\">
              <td data-slot=\"table-cell\">API</td>
              <td data-slot=\"table-cell\">Platform</td>
              <td data-slot=\"table-cell\">Healthy</td>
            </tr>
            <tr data-slot=\"table-row\">
              <td data-slot=\"table-cell\">Worker</td>
              <td data-slot=\"table-cell\">Backend</td>
              <td data-slot=\"table-cell\">Degraded</td>
            </tr>
          </tbody>
          <tfoot data-slot=\"table-footer\">
            <tr data-slot=\"table-row\">
              <td data-slot=\"table-cell\" colspan=\"3\">Last updated 2 minutes ago</td>
            </tr>
          </tfoot>
          """,
          """
          <.table_caption>Deployment status</.table_caption>
          <.table_header>
            <.table_row>
              <.table_head>Service</.table_head>
              <.table_head>Owner</.table_head>
              <.table_head>Status</.table_head>
            </.table_row>
          </.table_header>
          <.table_body>
            <.table_row>
              <.table_cell>API</.table_cell>
              <.table_cell>Platform</.table_cell>
              <.table_cell>Healthy</.table_cell>
            </.table_row>
            <.table_row>
              <.table_cell>Worker</.table_cell>
              <.table_cell>Backend</.table_cell>
              <.table_cell>Degraded</.table_cell>
            </.table_row>
          </.table_body>
          <.table_footer>
            <.table_row>
              <.table_cell>Last updated 2 minutes ago</.table_cell>
            </.table_row>
          </.table_footer>
          """
        )
    }
  end

  defp sample_assigns(DataDisplay, :table_body),
    do: %{
      inner_block:
        slot(
          ~S(<tr data-slot="table-row"><td data-slot="table-cell">Cell</td></tr>),
          """
          <.table_row>
            <.table_cell>Cell</.table_cell>
          </.table_row>
          """
        )
    }

  defp sample_assigns(DataDisplay, :table_caption), do: %{inner_block: slot("Table caption")}
  defp sample_assigns(DataDisplay, :table_cell), do: %{inner_block: slot("Cell")}

  defp sample_assigns(DataDisplay, :table_footer),
    do: %{
      inner_block:
        slot(
          ~S(<tr data-slot="table-row"><td data-slot="table-cell">Footer</td></tr>),
          """
          <.table_row>
            <.table_cell>Footer</.table_cell>
          </.table_row>
          """
        )
    }

  defp sample_assigns(DataDisplay, :table_head), do: %{inner_block: slot("Head")}

  defp sample_assigns(DataDisplay, :table_header),
    do: %{
      inner_block:
        slot(
          ~S(<tr data-slot="table-row"><th data-slot="table-head">Head</th></tr>),
          """
          <.table_row>
            <.table_head>Head</.table_head>
          </.table_row>
          """
        )
    }

  defp sample_assigns(DataDisplay, :table_row),
    do: %{
      inner_block: slot("<td data-slot=\"table-cell\">Row</td>", "<.table_cell>Row</.table_cell>")
    }

  defp sample_assigns(Navigation, :breadcrumb) do
    %{
      inner_block:
        slot(
          """
          <ol data-slot=\"breadcrumb-list\" class=\"flex items-center gap-2\">
            <li data-slot=\"breadcrumb-item\"><a data-slot=\"breadcrumb-link\" href=\"#\">Home</a></li>
            <li data-slot=\"breadcrumb-separator\">/</li>
            <li data-slot=\"breadcrumb-item\"><span data-slot=\"breadcrumb-page\">Docs</span></li>
          </ol>
          """,
          """
          <.breadcrumb_list>
            <.breadcrumb_item>
              <.breadcrumb_link href="#">Home</.breadcrumb_link>
            </.breadcrumb_item>
            <.breadcrumb_separator>/</.breadcrumb_separator>
            <.breadcrumb_item>
              <.breadcrumb_page>Docs</.breadcrumb_page>
            </.breadcrumb_item>
          </.breadcrumb_list>
          """
        )
    }
  end

  defp sample_assigns(Navigation, :breadcrumb_ellipsis), do: %{}
  defp sample_assigns(Navigation, :breadcrumb_item), do: %{inner_block: slot("Item")}
  defp sample_assigns(Navigation, :breadcrumb_link), do: %{href: "#", inner_block: slot("Home")}

  defp sample_assigns(Navigation, :breadcrumb_list),
    do: %{
      inner_block:
        slot(
          "<li data-slot=\"breadcrumb-item\">Item</li>",
          "<.breadcrumb_item>Item</.breadcrumb_item>"
        )
    }

  defp sample_assigns(Navigation, :breadcrumb_page), do: %{inner_block: slot("Current")}
  defp sample_assigns(Navigation, :breadcrumb_separator), do: %{}

  defp sample_assigns(Navigation, :navigation_menu) do
    %{
      item: [
        %{href: "#", active: true, inner_block: fn _, _ -> "Overview" end},
        %{href: "#", inner_block: fn _, _ -> "Settings" end}
      ]
    }
  end

  defp sample_assigns(Navigation, :menu) do
    %{
      item: [
        %{href: "#", active: true, inner_block: fn _, _ -> "Overview" end},
        %{href: "#", inner_block: fn _, _ -> "Team" end},
        %{href: "#", disabled: true, inner_block: fn _, _ -> "Billing" end}
      ]
    }
  end

  defp sample_assigns(Navigation, :pagination) do
    %{
      inner_block:
        slot(
          """
          <ul data-slot=\"pagination-content\" class=\"flex items-center gap-1\">
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-previous\" href=\"#\">Previous</a></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">1</a></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">2</a></li>
            <li data-slot=\"pagination-item\"><span data-slot=\"pagination-ellipsis\">…</span></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">8</a></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-next\" href=\"#\">Next</a></li>
          </ul>
          """,
          """
          <.pagination_content>
            <.pagination_item>
              <.pagination_previous href="#" />
            </.pagination_item>
            <.pagination_item>
              <.pagination_link href="#" size={:sm}>1</.pagination_link>
            </.pagination_item>
            <.pagination_item>
              <.pagination_link href="#" size={:sm} active={true}>2</.pagination_link>
            </.pagination_item>
            <.pagination_item>
              <.pagination_ellipsis />
            </.pagination_item>
            <.pagination_item>
              <.pagination_link href="#" size={:sm}>8</.pagination_link>
            </.pagination_item>
            <.pagination_item>
              <.pagination_next href="#" />
            </.pagination_item>
          </.pagination_content>
          """
        )
    }
  end

  defp sample_assigns(Navigation, :pagination_content),
    do: %{
      inner_block:
        slot(
          "<li data-slot=\"pagination-item\">Page</li>",
          "<.pagination_item>Page</.pagination_item>"
        )
    }

  defp sample_assigns(Navigation, :pagination_ellipsis), do: %{}
  defp sample_assigns(Navigation, :pagination_item), do: %{inner_block: slot("Item")}

  defp sample_assigns(Navigation, :pagination_link),
    do: %{href: "#", active: true, inner_block: slot("1")}

  defp sample_assigns(Navigation, :pagination_next), do: %{href: "#"}
  defp sample_assigns(Navigation, :pagination_previous), do: %{href: "#"}

  defp sample_assigns(Navigation, :tabs) do
    %{
      value: "overview",
      trigger: [
        %{value: "overview", inner_block: fn _, _ -> "Overview" end},
        %{value: "settings", inner_block: fn _, _ -> "Settings" end}
      ],
      content: [
        %{value: "overview", inner_block: fn _, _ -> "Overview content" end},
        %{value: "settings", inner_block: fn _, _ -> "Settings content" end}
      ]
    }
  end

  defp sample_assigns(Overlay, :alert_dialog) do
    cancel_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Cancel")
      })

    %{
      id: "docs-alert-dialog",
      open: false,
      trigger: slot("Open"),
      title: slot("Delete project?"),
      description: slot("This action is irreversible."),
      inner_block: slot("Dialog body"),
      footer:
        slot(
          cancel_button_html,
          "<.button variant={:outline} size={:sm}>Cancel</.button>"
        )
    }
  end

  defp sample_assigns(Overlay, :dialog) do
    done_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Done")
      })

    %{
      id: "docs-dialog",
      open: false,
      trigger: slot("Open"),
      title: slot("Dialog title"),
      description: slot("Dialog description"),
      inner_block: slot("Dialog body"),
      footer:
        slot(
          done_button_html,
          "<.button variant={:outline} size={:sm}>Done</.button>"
        )
    }
  end

  defp sample_assigns(Overlay, :drawer) do
    save_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Save")
      })

    %{
      id: "docs-drawer",
      open: false,
      side: :bottom,
      trigger: slot("Open"),
      title: slot("Drawer"),
      description: slot("Bottom drawer description"),
      inner_block: slot("Drawer body"),
      footer:
        slot(
          save_button_html,
          "<.button variant={:outline} size={:sm}>Save</.button>"
        )
    }
  end

  defp sample_assigns(Overlay, :dropdown_menu) do
    %{
      id: "docs-dropdown",
      trigger: slot("Actions"),
      item: [
        %{href: "#", inner_block: fn _, _ -> "Settings" end},
        %{href: "#", inner_block: fn _, _ -> "Billing" end}
      ]
    }
  end

  defp sample_assigns(Overlay, :hover_card) do
    %{trigger: slot("Hover card"), content: slot("Hover content")}
  end

  defp sample_assigns(Overlay, :menubar) do
    new_button_html =
      render_component(Actions, :button, %{
        variant: :ghost,
        size: :sm,
        class: "w-full justify-start",
        inner_block: slot("New")
      })

    %{
      menu: [
        %{
          label: "File",
          inner_block: fn _, _ -> HTML.raw(new_button_html) end,
          template:
            "<.button variant={:ghost} size={:sm} class=\"w-full justify-start\">New</.button>"
        }
      ]
    }
  end

  defp sample_assigns(Overlay, :popover) do
    %{id: "docs-popover", trigger: slot("Popover"), content: slot("Popover content")}
  end

  defp sample_assigns(Overlay, :sheet) do
    sample_assigns(Overlay, :drawer)
    |> Map.put(:id, "docs-sheet")
    |> Map.put(:side, :right)
    |> Map.put(:title, slot("Sheet"))
    |> Map.put(:description, slot("Side panel description"))
  end

  defp sample_assigns(Overlay, :tooltip),
    do: %{
      text: "Tooltip text",
      # The trigger can be any interactive component.
      inner_block:
        slot(
          render_component(Actions, :button, %{
            variant: :outline,
            size: :sm,
            inner_block: slot("Hover me")
          }),
          """
          <.button variant={:outline} size={:sm}>Hover me</.button>
          """
        )
    }

  defp sample_assigns(Advanced, :calendar) do
    not_ready_html =
      render_component(Feedback, :badge, %{
        variant: :secondary,
        inner_block: slot("Not ready yet")
      })

    %{
      inner_block:
        slot(
          "<div class=\"space-y-2\">#{not_ready_html}<p class=\"text-sm text-muted-foreground\">Calendar is not ready yet.</p></div>",
          """
          <.badge variant={:secondary}>Not ready yet</.badge>
          <p class=\"text-sm text-muted-foreground\">Calendar is not ready yet.</p>
          """
        )
    }
  end

  defp sample_assigns(Advanced, :carousel) do
    %{
      id: "docs-carousel",
      item: [
        %{
          inner_block: fn _, _ -> HTML.raw("<div class=\"h-24 rounded-md bg-muted\"></div>") end,
          template: "<div class=\"h-24 rounded-md bg-muted\"></div>"
        },
        %{
          inner_block: fn _, _ ->
            HTML.raw("<div class=\"h-24 rounded-md bg-muted/60\"></div>")
          end,
          template: "<div class=\"h-24 rounded-md bg-muted/60\"></div>"
        }
      ]
    }
  end

  defp sample_assigns(Advanced, :chart) do
    %{
      title: slot("Requests"),
      description: slot("Last 24h"),
      inner_block: slot("<div class=\"h-24 rounded bg-muted\"></div>")
    }
  end

  defp sample_assigns(Advanced, :combobox) do
    %{
      id: "docs-combobox",
      value: "Pro",
      option: [%{value: "Free", label: "Free"}, %{value: "Pro", label: "Pro"}]
    }
  end

  defp sample_assigns(Advanced, :command) do
    command_palette_assigns()
  end

  defp sample_assigns(Advanced, :item), do: %{value: "profile", inner_block: slot("Profile")}

  defp sample_assigns(Advanced, :sidebar) do
    %{
      rail: slot("<nav class=\"space-y-2 text-sm\"><p>Dashboard</p><p>Settings</p></nav>"),
      inset: slot("<div class=\"rounded bg-muted p-4 text-sm\">Main content</div>")
    }
  end

  defp sample_assigns(Components, _function), do: %{}

  defp avatar_sample_data_uri(:levi), do: @avatar_levi
  defp avatar_sample_data_uri(:ari), do: @avatar_shadcn
  defp avatar_sample_data_uri(:mira), do: @avatar_mira
  defp avatar_sample_data_uri(:noor), do: @avatar_mira

  defp slot(content, template_content \\ nil) do
    [
      %{
        inner_block: fn _, _ -> HTML.raw(content) end,
        template: template_content
      }
    ]
  end
end
