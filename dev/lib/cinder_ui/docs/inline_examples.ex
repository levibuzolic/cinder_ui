defmodule CinderUI.Docs.InlineExamples do
  @moduledoc false

  @example_section_headings MapSet.new(
                              ~w(example examples usage variant variants screenshot screenshots)
                            )

  def parse(doc) when is_binary(doc) do
    (fenced_doc_examples(doc) ++ indented_doc_examples(doc))
    |> Enum.uniq()
    |> Enum.with_index(1)
    |> Enum.map(fn {{lang, title, preview_align, promoted_visual, code}, index} ->
      %{
        id: "inline-#{index}",
        title: inline_doc_example_title(title, lang, index),
        template_heex: code,
        preview_align: preview_align,
        promoted_visual: promoted_visual,
        phoenix_shim: phoenix_shim_example?(code)
      }
    end)
  end

  defp fenced_doc_examples(doc) do
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
  end

  defp indented_doc_examples(doc) do
    {_index, examples, _inside_fence, _section_level, _inside_examples_section, _heading_title} =
      doc
      |> String.trim()
      |> String.split("\n")
      |> collect_indented_examples({0, [], false, nil, false, nil})

    Enum.reverse(examples)
  end

  defp collect_indented_examples(lines, state)

  defp collect_indented_examples(
         lines,
         {index, examples, inside_fence, section_level, inside_examples_section, heading_title}
       ) do
    case Enum.fetch(lines, index) do
      :error ->
        {index, examples, inside_fence, section_level, inside_examples_section, heading_title}

      {:ok, line} ->
        trimmed = String.trim_leading(line)

        cond do
          String.starts_with?(trimmed, "```") ->
            collect_indented_examples(
              lines,
              {index + 1, examples, !inside_fence, section_level, inside_examples_section,
               heading_title}
            )

          inside_fence ->
            collect_indented_examples(
              lines,
              {index + 1, examples, inside_fence, section_level, inside_examples_section,
               heading_title}
            )

          true ->
            collect_doc_line(
              lines,
              line,
              trimmed,
              {index, examples, inside_fence, section_level, inside_examples_section,
               heading_title}
            )
        end
    end
  end

  defp collect_doc_line(lines, line, trimmed, state) do
    {index, examples, inside_fence, section_level, inside_examples_section, heading_title} = state

    case heading_metadata(trimmed) do
      {:heading, level, title} ->
        {next_section_level, next_inside_examples_section, next_heading_title} =
          update_heading_context(
            level,
            title,
            section_level,
            inside_examples_section,
            heading_title
          )

        collect_indented_examples(
          lines,
          {
            index + 1,
            examples,
            inside_fence,
            next_section_level,
            next_inside_examples_section,
            next_heading_title
          }
        )

      :not_heading ->
        collect_body_line(lines, line, state)
    end
  end

  defp collect_body_line(lines, line, state) do
    {index, examples, inside_fence, section_level, inside_examples_section, heading_title} = state

    if inside_examples_section and String.starts_with?(line, "    ") do
      {next_index, code} = take_indented_block(lines, index)
      normalized_code = String.trim(code)

      next_examples =
        if normalized_code != "" and String.contains?(normalized_code, "<.") do
          [{"", heading_title, :center, false, normalized_code} | examples]
        else
          examples
        end

      collect_indented_examples(
        lines,
        {
          next_index,
          next_examples,
          inside_fence,
          section_level,
          inside_examples_section,
          heading_title
        }
      )
    else
      collect_indented_examples(
        lines,
        {index + 1, examples, inside_fence, section_level, inside_examples_section, heading_title}
      )
    end
  end

  defp heading_metadata(line) do
    case Regex.run(~r/^(#+)\s+(.+?)\s*$/, line, capture: :all_but_first) do
      [hashes, title] -> {:heading, String.length(hashes), String.trim(title)}
      _ -> :not_heading
    end
  end

  defp update_heading_context(
         level,
         title,
         section_level,
         inside_examples_section,
         _heading_title
       ) do
    normalized_title = normalize_heading_title(title)

    cond do
      MapSet.member?(@example_section_headings, normalized_title) ->
        {level, true, nil}

      inside_examples_section and is_integer(section_level) and level > section_level ->
        {section_level, true, title}

      true ->
        {nil, false, nil}
    end
  end

  defp normalize_heading_title(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.trim()
  end

  defp take_indented_block(lines, start_index) do
    lines
    |> Enum.drop(start_index)
    |> Enum.split_while(&String.starts_with?(&1, "    "))
    |> then(fn {chunk, _rest} ->
      code =
        chunk
        |> Enum.map_join("\n", &String.trim_leading(&1, "    "))

      {start_index + length(chunk), code}
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

  defp phoenix_shim_example?(code) when is_binary(code), do: String.contains?(code, "@form[")
end
