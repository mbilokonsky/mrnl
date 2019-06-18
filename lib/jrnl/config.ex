defmodule Jrnl.Config do
  def read do
    path()
    |> File.read!()
    |> Poison.decode!()
  end

  def write(data) do
    backup()
    File.write!(path(), Poison.encode!(data))
    "Your .jrnl config has been updated. See backup for prior state."
  end

  def backup do
    backup_path = path() <> "_backup_#{DateTime.utc_now()}"
    File.copy(path(), backup_path)
  end

  def path do
    "~/.jrnl_config" |> Path.expand()
  end
end
