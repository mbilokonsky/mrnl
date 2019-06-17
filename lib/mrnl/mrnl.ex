defmodule Mrnl do
	def ls do
		Jrnl.ls()
	end

	def write(journal_name, text) do
		Jrnl.write(journal_name, text)
	end

	def edit(journal_name), do: edit(journal_name, "")
  def edit(journal_name, selector) do
    Jrnl.edit(journal_name, selector)
  end

	def tags(journal_name) do
		Jrnl.tags(journal_name)
	end

	def config do
		Jrnl.Config.read()
	end

	def history(journal_name), do: history(journal_name, [])
	def history(journal_name, tags), do: history(journal_name, tags, false)
	def history(journal_name, tags, edit) do
		Jrnl.history(journal_name, tags, edit)
		|> String.split("\n")
		|> Enum.map(&(Jrnl.Utils.parse_short_line/1))
		|> Enum.filter(fn x -> x != nil end)
	end
end
