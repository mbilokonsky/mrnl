defmodule Mood do
  def new(mood, edit) do
    moods = ["great", "good", "ok", "blank", "meh", "bad", "horrible"]
    entry = "Mood: @#{mood || Mio.choice("How do you feel?", moods)}"
    Mrnl.write("mood", entry)

    if edit do
      Mrnl.edit("mood", "-1")
    end
  end

  def history(), do: history([])
  def history(tags), do: history(tags, false)

  def history(tags, edit) do
    Mrnl.history("mood", tags, edit)
  end
end
