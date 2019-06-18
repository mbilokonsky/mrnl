defmodule Mood do
  @moods ["great", "good", "ok", "blank", "meh", "bad", "horrible"]

  def new(mood, edit) do
    if :error == Enum.find(@moods, :error, fn i -> i == mood end) do
      IO.puts("Invalid mood provided. It should be one of [#{Enum.join(@moods, ", ")}]")
      IO.puts("No data was written.")
      System.halt()
    end

    entry = "Mood: @#{mood || Mio.choice("How do you feel?", @moods)}"
    Mrnl.write("mood", entry)

    if edit do
      Mrnl.edit("mood", "-1")
    end
  end

  def history(), do: history([])
  def history(tags), do: history(tags, false)

  def history(tags, edit) do
    Mrnl.history("mood", tags, edit)
    |> Enum.map(fn %{tags: t} ->
      case t do
        ["@great"] -> 3
        ["@good"] -> 2
        ["@ok"] -> 1
        ["@blank"] -> 0
        ["@meh"] -> -1
        ["@bad"] -> -2
        ["@horrible"] -> -3
        _ -> IO.puts("WTF? ->" <> t <> "<- SHAME!")
      end
    end)
    |> Sparkline.sparkline(minmax: {-3, 3}, spark_bars: ["▂", "▃", "▄", "▅", "▆", "▇", "█"])
  end
end
