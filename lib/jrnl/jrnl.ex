defmodule Jrnl do
  defp jrnl(args), do: jrnl(args, false)

  defp jrnl(args, debug) do
    arg_string = Enum.join(args, " ")

    if debug do
      IO.puts("About to invoke `jrnl #{arg_string}`")
    end

    {result, _exit} = System.cmd("jrnl", args)
    result
  end

  def write(journal_name, text) do
    jrnl([journal_name, text])
  end

  def edit(journal_name), do: edit(journal_name, "")

  def edit(journal_name, selector) do
    jrnl([journal_name, selector, "--edit"])
  end

  def ls() do
    jrnl(["-ls"])
    |> String.trim()
    |> String.split("\n")
  end

  def tags(journal_name) do
    jrnl([journal_name, "--tags"])
    |> String.trim()
    |> String.split("\n")
  end

  def history(journal_name), do: history(journal_name, [], true)
  def history(journal_name, tags), do: history(journal_name, tags, false)

  def history(journal_name, tags, edit) do
    tags = Jrnl.Utils.format_tags(tags)

    input = [journal_name]
    input = if tags != "", do: Enum.concat(input, [tags]), else: input
    input = if edit, do: Enum.concat(input, ["--edit"]), else: input
    input = Enum.concat(input, ["--short"])

    jrnl(input)
  end
end
