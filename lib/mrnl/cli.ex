defmodule Mrnl.CLI do
	def log(%{ verbose: 0 }) do end
	def log(context, cmd) do
		verbose = context[:verbose] || 0
		if verbose > 0 do
			IO.puts("[#{DateTime.utc_now}] running command #{cmd}")
		end

		if verbose > 1 do
			IO.inspect(context)
		end

		if verbose > 2 do
			System.cmd("say", ["Running command #{cmd}"])
		end

		context
	end

	use ExCLI.DSL, escript: true
  option(:v, help: "Increase the verbosity level", count: true, as: :verbose, default: 0)

  command :ls do
    description("Lists all current journals")

		run context do
			log(context, :ls)
			Mrnl.ls() |> IO.inspect()
    end
  end

  command :tags do
    description("Lists all tags used in specified journal")
    argument(:journal_name, default: nil, help: "May be one: #{Jrnl.ls() |> Enum.join("| ")}")

    run context do
      log(context, :tags)
      Mrnl.tags(context.journal_name) |> IO.inspect()
    end
  end

	command :config do
		description("Posts the jrnl config file")
    run context do
			log(context, :config)
			Mrnl.config |> Poison.encode() |> IO.inspect()
    end
  end

  command :kb do
    description("Adds an entry to the knowledgebank")

    run context do
      log(context, :kb)
			KB.new
    end
	end

	command :mood do
		description("Logs your mood to your mood log!")

		option :mood, aliases: [:m], default: nil
		option :edit, aliases: [:e], type: :boolean, help: "Open entry for editing?"
		option :history, type: :boolean, help: "Get history instead of writing an entry"
		option :tags, type: :boolean, help: "If getting history, constrain by some tags"

		run context do
			log(context, :mood)

			tags = if context[:history] != nil and context[:tags] != nil do
				Mio.prompt_list("Enter tags you want to add: ")
			else
				[]
			end

			case context[:history] do
				true -> Mood.history(tags, context[:edit]) |> IO.inspect
				_ -> Mood.new(context[:mood], context[:edit]) |> IO.puts
			end
		end
	end

	command :test do
		run _context do
			Mio.choice("Favorite color?", "Choose", ["red", "blue", "green", "yellow"])
		end
	end
end
