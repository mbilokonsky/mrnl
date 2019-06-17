defmodule Jrnl.Utils do
	def format_tags(tags) do
		tags
		|> Enum.map(fn tag ->
			case tag do
				"@" <> _ -> tag
				"" -> :remove_me
				_ -> "@#{tag}"
			end
		end)
		|> Enum.filter(fn t -> t != :remove_me end)
		|> Enum.join(" ")
		|> String.trim
	end

	def parse_short_line(line) do
		unless line == "" do
			<<
				date::binary-size(10),
				" ",
				time :: binary-size(5),
				" ",
				entry::binary
			>> = line
			# strips any ANSI codes
			entry = String.replace(entry, ~r/\x1b\[[0-9;]*[mG]/, "")
			length = String.length(entry)
			tags = String.split(entry, "\n")
			|> Enum.flat_map(fn line ->
				String.split(line, " ") |> Enum.filter(fn word ->
					case word do
						"@" <> _ -> true
						_ -> false
					end
				end)
			end)

			%{ date: date, time: time, entry_size: length, tags: tags, entry: entry }
		end
	end
end
