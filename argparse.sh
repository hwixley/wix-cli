#!/bin/bash

# CLI CONSTS
version="1.1.0"
num_args=$#
date=$(date)
year="${date:24:29}"

# Load bash classes
source $(dirname ${BASH_SOURCE[0]})/src/classes/sys/sys.h
sys sys
source $(dirname ${BASH_SOURCE[0]})/src/classes/wgit/wgit.h
wgit wgit
source $(dirname ${BASH_SOURCE[0]})/src/classes/user/user.h
user user
source $(dirname ${BASH_SOURCE[0]})/src/classes/wixd/wixd.h
wixd wixd

# Load source git data
branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
fi
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}


if [ $num_args -eq 0 ]; then
	# No input - show command info
	wixd.command_info

else
	source $(dirname ${BASH_SOURCE[0]})/src/classes/command/command.h
	# Parse input into command object and run it (if valid)
	command inputCommand
	inputCommand.id '=' "$1"
	inputCommand_path="${WIX_DIR}/src/commands/$(inputCommand.path).sh"

	if [ -f "${inputCommand_path}" ]; then
		# Valid command found - run it
		source "${inputCommand_path}" "${@:2}"

	else
		# Invalid command - show error message
		sys.error "Invalid command! Try again"
		echo "Type 'wix' to see the list of available commands (and their arguments), or 'wix help' to be redirected to more in-depth online documentation"
	fi
fi
