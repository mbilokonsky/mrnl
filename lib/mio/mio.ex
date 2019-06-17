defmodule Mio do
  def prompt(text) do
    IO.gets(text) |> String.trim()
  end

  def prompt_list(text), do: prompt_list(text, " ")

  def prompt_list(text, delimiter) do
    prompt(text) |> String.trim() |> String.split(delimiter)
  end

	def choice(text, options), do: choice(text, "Make your choice", options)
  def choice(text, prompt_text, options) do
    IO.puts(IO.ANSI.clear_line() <> IO.ANSI.cursor_left(500) <> text)
		size = render_options(options)
		prepare_input_region()

		get_selection(prompt_text <> " (between 1-#{size})", size, options)
  end

	defp render_options(options) do
		size = length(options)

		1..size
    |> Stream.zip(options)
		|> Stream.map(fn {index, option} ->
			case index do
				1 -> IO.ANSI.clear_line() <> format_option(index, option)
				_ -> format_option(index, option)
			end
		end)
    |> Enum.join("   ")
		|> IO.puts()

		size
	end

	defp format_option(index, option) do
		"#{index}) #{option}"
	end

	defp prepare_input_region do
		IO.puts("")
		IO.write(IO.ANSI.cursor_up(1))
	end

	defp get_selection(prompt, size, options), do: get_selection(prompt, size, options, "")
	defp get_selection(prompt, size, options, prefix) do
		output = case request_answer(prefix <> prompt) do
			i when (0 <= i and i <= size - 1) -> Enum.at(options, i)
			_ -> get_selection(
						prompt,
						size,
						options,
						IO.ANSI.cursor_up(1) <> IO.ANSI.clear_line <> IO.ANSI.cursor_left(500)
					)
		end
		# something here to highlight selection, require 'enter' to fully submit?
		output
	end

	defp request_answer(prompt) do
		case IO.gets(prompt <> ": ") |> Integer.parse() do
      {choice, _} -> choice - 1
      :error -> :error
		end
	end
end
