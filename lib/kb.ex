defmodule KB do
  def new do
    query = Mio.prompt("What question is this entry answering? ")
    query_string = query <> "\n\n"

    tags =
      Mio.prompt_list("What tags apply to this? ")
      |> Jrnl.Utils.format_tags()

    tag_string = "Tags: " <> tags <> "\n\n"

    Mrnl.write("kb", query_string <> tag_string)
    Mrnl.edit("kb", "-1")
  end

  def history do
    Mrnl.history("kb")
  end
end
