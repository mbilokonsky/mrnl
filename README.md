# Mrnl

Right now this is primarily an exercise in learning how to use elixir to build command-line apps. Mrnl is still under construction, and will likely evolve into multiple packages published to hex which I'll document here.


## Jrnl
`lib/jrnl` is just a raw wrapper around `jrnl.sh` that exposes certain combinations of arguments.

### Jrnl.write(journal_name, text)
This takes the journal name as the initial argument and then the text to write as the second. Note that if you do submit a jrnl-specific command in your text that this will still execute that command, so like, this is how you just 'invoke' jrnl. But doing so that way is against the spirit of what I'm trying to achieve here. Eventually I'll try to add filters to this to ensure you can't accidentally set a timestamp or do a query or whatever.

* `journal_name` is required
* `text` is the entry you want to submit

### Jrnl.edit(journal_name, selector // "")
This is used to edit a given journal using an optional selector. When invoked it'll open whatever you select in a text editor, and it'll wait until you close the text editor before moving on.

* `journal_name` is required.
* `selector` is optional, and will constrain the set of values you get back to

Most frequently I use this to implement the `--edit` boolean option for other commands. For instance, there are times you want to add a journal entry and then immediately edit it (`Jrnl.edit("some_journal", "-1")`). You can also use this to edit an entire journal (`Jrnl.edit("some_journal")`).

### Jrnl.ls()
This will list all of the current journals in your `.jrnl_config` file.

### Jrnl.tags(journal_name)
This returns a sorted list of all tags that appear in a given journal. You have to pass in the journal name.

### history(journal_name, tags // [], edit // false)
This returns a list of truncated journal entries that satisfy some criteria.

* `journal_name` is required.
* if `tags` contains any values it'll constrain the history search to those entries that include any of the provided tags.
* if `edit` is `true` then it'll open your history in a text editor and wait for you to close it before moving out.

### Jrnl.Config.read()
This returns the contents of `~/.jrnl_config` as a map generated from the JSON in the file.

### Jrnl.Config.write(new_config_map)
This takes a map that can be parsed into a JSON string, which is then written to `~/.jrnl_config`. Because this is a destructive operation it will also call `Jrnl.Config.backup()` for you.

### Jrnl.Config.backup()
This copies the value of `~/.jrnl_config` to `~/.jrnl_config_<timestamp>`. Invoked automatically when writing.

## Mio
`Mio` is intended as a set of IO abstractions for accepting user CLI input. This is for those cases when you want something a bit more robust than just `IO.gets`, though elixir has some limitations around how well it can handle keyboard input. It seems like the user has to press enter before anything is read, which means that CLI UI's where e.g. the arrow keys are used to navigate between choices are right now impossible to write in Elixir without bringing in the monster that is `ncurses`.

But this is a start!

### Mio.prompt(text)
This is a wrapper for `IO.gets` which trims the response before returning it.

* `text` is the prompt with which the user will be greeted.

### MIO.prompt_list(text, delimiter // " ")
This calls `Mio.prompt(text)` but then splits the returned string using the provided delimiter and returns a list.

* `text` is the prompt with which the user will be greeted.
* `delimiter` will be used to split the user's answer into a list.

### MIO.choice(text, prompt_text // "Make your choice", options)
This is my favorite one of these so far. It'll print out the `text`, then it'll print out your `options` with numbers next to them. Then it'll print out the `prompt_text`, and it'll wait until the user inputs a number.

* `text` is the prompt with which the user will be greeted.
* `prompt_text` is what shows up when the user is asked for input
* `options` are a list of strings to be presented as options. This function will return an item from this list.

If the user inputs anything other than a number, or if the user inputs a number larger than the available range, the user won't be able to continue. They'll be gently prompted to please provide a valid number between 1 and `length(options)`. What I like about this is that it'll use the `IO.ANSI` package to move the cursor around and overwrite old lines when the user enters bogus input, so it's always constrained to the three (well, four - the first time the user presses enter it adds a newline to the end and I can't figure out how to change that) lines it generates.


## Mrnl
The idea is that `Mrnl` will expose various primitives for reading/writing data in and out of `Jrnl`. `Jrnl` is going to remain pretty close to the metal - I want to preserve their CLI interface and return raw strings. Take a look at `Mrnl.history` -- we invoke `Jrnl.history`, but then we take the test we get back and process it into a list of data structures.

The goal is eventually to layer customizations here. I want to be able to generate a sparkline of my mood over the past week, or generate a gatsby blog from the entries in one of my journals.

### Usage

Right now this API is primarily consumed through the `Mrnl.CLI` module, which exposes a number of command line tools for working with journals. See `lib/mrnl/cli.ex` to understand how this all works.

* `ls`, `tags` and `config` are basically directly invoking `Mrnl` which directly invokes `Jrnl` for these commands.
* `kb` is for working with my "knowledge bank" journal. This command allows me to add new items to the knowledge base.
* `mood` is for working with my "mood" journal - it allows me to log my current mood, and using the CLI options I can either do this in a one-line fire-and-forget or I can have it ask me to choose from a list. I also have the option, using the `--history` option, to instead get a list of my past moods.


## Actual Journals
The goal here is to facilitate a number of 'actual' journals with their own APIs. I'm still not quite sure how I want to structure this - probably each journal becomes its own project in the end, with its own CLI interface, and I pull `Mrnl` in as a dependency. For now though they're just organically evolving here. What I have so far is simple, but once the fundamentals are solid it'll be time for some fun integrations! :)

### KB
This is an individual journal that's being managed through `Mrnl`'s CLI tooling. I use it to keep track of things I've learned.

#### KB.new
This is how I add an entry to my knowledge base. It'll prompt me to answer two questions:
1. What question am I trying to answer?
2. What tags do I want to include in this entry?

Then it'll generate a new entry based on my answers and automatically open it up for editing. It waits until I'm done before moving on.

#### KB.history
This is a pass-through, it'll return my entire KB history. I need to have this support tags and optional editing.

### Mood
This is another individual journal that's being managed through `Mrnl`. I'm using it to track my moods over time as part of a larger mental health practice.

#### Mood.new(mood // nil, edit // false)
If you pass in `mood` this will just log an entry with that mood to the journal. If you don't, it'll prompt you to select one of the seven pre-determined moods, then write that to the journal. If `edit` is true it'll then open the journal for you to add additional notes/context.

#### Mood.history(tags// [], edit // false)
This shows you all of your past entries. If you want you can include tags in the `tags` array and it'll constrain the returned value to only those entries that satisfy at least one tag.

### Etc
I plan to add a few more domain-specific journals here. One for todos, one for upcoming events, etc. I want to see if I can't organize my whole life around specific journals, with automated reminders to read and write them in ways that matter.


## Installation
Best way to run this right now is to fork this repo and pull it down. Then take the following steps:

1. Make sure you have `jrnl.sh` installed. If you want to use `kb` or `mood`, you should add `kb` and `mood` journals to your `~/.jrnl_config` file.
2. cd into the directory where you pulled this down and run `mix deps.get`
3. run `mix escript.build`
4. try it out! One neat place to start may be to run `/.mrnl kb` and create an item for your personal knowledge base!

### VSCode configuration
If you install the [vs-code-elixir](https://marketplace.visualstudio.com/items?itemName=mjmcloug.vscode-elixir) extension this will rebuild every time you save a file. If you don't have this extension installed you may see weird errors - you can go ahead and remove `"triggerTaskOnSave.tasks"` from `.vscode/settings.json` and your problems should stop.
