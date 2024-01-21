#!/bin/bash

# CLI CONSTS
version="1.1.0"
num_args=$#
date=$(date)
year="${date:24:29}"

source $(dirname ${BASH_SOURCE[0]})/src/classes/sys/sys.h
source $(dirname ${BASH_SOURCE[0]})/src/classes/wgit/wgit.h
sys sys
wgit wgit


# DATA


branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
	branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
fi
remote=$(git config --get remote.origin.url | sed 's/.*\/\([^ ]*\/[^.]*\).*/\1/')
repo_url=${remote#"git@github.com:"}
repo_url=${repo_url%".git"}


# MODULAR FUNCTIONS
arggt() {
	if [ "$num_args" -gt "$1" ]; then
		return 0
	else
		return 1
	fi	
}

direxists() {
	if [[ -v mydirs[$1] ]]; then
		return 0
	else
		return 1
	fi
}

orgexists() {
	if [[ -v myorgs[$1] ]]; then
		return 0
	else
		return 1
	fi
}

scriptexists() {
	if [[ -v myscripts[$1] ]]; then
		return 0
	else
		return 1
	fi
}

check_keystore() {
	envfile="$WIX_DATA_DIR/.env"
	if [[ -f "$sys.envfile" ]]; then
		# Check if key-value pair exists in .env file
		if grep -q "^$1=" "$sys.envfile"; then
			# Prompt user to replace the existing value
			read -rp "${GREEN}Key \"$1\" already exists. Do you want to replace the value? (y/n):${RESET} " choice
			if [[ $choice == "y" || $choice == "Y" ]]; then
				if [ -n "$2" ]; then
					# Replace the value in .env
					sed -i "s/^$1=.*/$1=$2/" "$sys.envfile"
					sys.info "Value for key \"$1\" replaced successfully!"
				else
					# Prompt user to enter the value
					read -rp "${GREEN}Enter the value for \"$1\":${RESET} " value

					# Replace the value in .env
					sed -i "s/^$1=.*/$1=$value/" "$sys.envfile"
					sys.info "Value for key \"$1\" replaced successfully!"
				fi
			else
				sys.info "Value for key \"$1\" not replaced."
			fi
		else
			if [ -n "$2" ]; then
				# Append key-value pair to .env
				echo "$1=$2" >> "$sys.envfile"
				sys.info "Value for key \"$1\" appended successfully!"
			else
				# Prompt user to enter the value
				read -rp "${GREEN}Enter the value for \"$1\":${RESET} " value

				# Append key-value pair to .env
				echo "$1=$value" >> "$sys.envfile"
				sys.info "Value for key \"$1\" appended successfully!"
			fi
		fi
	else
		if [ -n "$2" ]; then
			# Create .env file and add the key-value pair
			echo "$1=$2" > "$sys.envfile"
			sys.info ".env file created successfully!"
			sys.info "Value for key \"$1\" appended successfully!"
		else
			# Prompt user to enter the value
			read -rp "${GREEN}Enter the value for \"$1\":${RESET} " value

			# Create .env file and add the key-value pair
			echo "$1=$value" > "$sys.envfile"
			sys.info ".env file created successfully!"
			sys.info "Value for key \"$1\" appended successfully!"
		fi
	fi
	echo ""
}






# COMMAND FUNCTIONS
wix_cd() {
	if arggt "1" ; then
		if direxists "$1" ; then
			destination="${mydirs[$1]/~/${HOME}}"
			if ! sys.empty "$2" ; then
				destination="${mydirs[$1]/~/${HOME}}/$2"
			fi
			sys.info "Travelling to -> $destination"
			eval cd "$destination" || (sys.error "The path $destination does not exist" && return 1)
			return 0
		else
			sys.error
			return 1
		fi
	else
		sys.info "Where do you want to go?"
		read -r dir
		if direxists "$dir" ; then
			sys.info "Travelling to -> ${mydirs[$dir]}"
			cd "${mydirs[$dir]:?}" || exit
			return 0
		else
			sys.error
			return 1
		fi
	fi
}

wix_new() {
	if direxists "$1" ; then
		if sys.empty "$2" ; then
			sys.info "Provide a name for this directory:"
			read -r dname
			sys.info "Generating new dir (${mydirs[$1]}/$dname)..."
			mkdir "${mydirs[$1]:?}/$dname"
			cd "${mydirs[$1]:?}/$dname" || exit
		else
			sys.info "Generating new dir (${mydirs[$1]}/$2)..."
			mkdir "${mydirs[$1]:?}/$2"
			cd "${mydirs[$1]:?}/$2" || exit
		fi
		return 0
	else
		sys.error
		return 1
	fi
}

wix_run() {
	if scriptexists "$1"; then
		sys.info "Running $1 script!"
		source "$WIX_DATA_DIR/run-configs/${myscripts[$1]}.sh"
	else
		sys.error "This is only supported for gs currently"
	fi
}



command_info() {
	echo "Welcome to the..."
	echo ""
	sys.info " ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}888P ${CYAN}8${BLUE}88 ${CYAN}Y${BLUE}8b Y8P${GREEN}     e88'Y88 888     888 "
	sys.info "  ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8P  ${CYAN}8${BLUE}88  ${CYAN}Y${BLUE}8b Y${GREEN}     d888  'Y 888     888 "
	sys.info "   ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}   ${CYAN}8${BLUE}88   ${CYAN}Y${BLUE}8b${GREEN}     C8888     888     888 "
	sys.info "    ${CYAN}Y${BLUE}8b ${CYAN}Y${BLUE}8b    ${CYAN}8${BLUE}88  e ${CYAN}Y${BLUE}8b${GREEN}     Y888  ,d 888  ,d 888 "
	sys.info "     ${CYAN}Y${BLUE}8P ${CYAN}Y${BLUE}     ${CYAN}8${BLUE}88 d8b ${CYAN}Y${BLUE}8b${GREEN}     \"88,d88 888,d88 888 "
	echo ""
	echo "v$version"
	echo ""
	sys.h1	"MAINTENANCE:"
	echo "- sys-info			${ORANGE}: view shell info${RESET}"
	echo "- update			${ORANGE}: update wix-cli${RESET}"
	echo "- install-deps			${ORANGE}: install dependencies${RESET}"
	echo ""
	sys.h1 "DIRECTORY NAVIGATION:"
	echo "- cd <mydir> 			${ORANGE}: navigation${RESET}"
	echo "- back 				${ORANGE}: return to last dir${RESET}"
	echo ""
	sys.h1 "CODE:"
	echo "- vsc <mydir>			${ORANGE}: open directory in Visual Studio Code${RESET}"
	if sys.using_zsh; then
		echo "- xc <mydir>			${ORANGE}: open directory in XCode${RESET}"
	fi
	echo "- run <myscript> 		${ORANGE}: setup and run environment${RESET}"
	echo ""
	sys.h1 "GITHUB AUTOMATION:"
	echo "- push <branch?>		${ORANGE}: push changes to repo branch${RESET}"
	echo "- pull <branch?>		${ORANGE}: pull changes from repo branch${RESET}"
	echo "- ginit <newdir?>		${ORANGE}: setup git repo in existing/new directory${RESET}"
	echo "- nb <name?>			${ORANGE}: create new branch${RESET}"
	echo "- pr 				${ORANGE}: create PR for branch${RESET}"
	echo "- bpr 				${ORANGE}: checkout changes to new branch and create PR${RESET}"
	echo "- commits			${ORANGE}: view commit history${RESET}"
	echo "- lastcommit			${ORANGE}: view last commit${RESET}"
	echo "- setup smart_commit		${ORANGE}: setup smart commit${RESET}"
	echo ""
	sys.h1 "URLS:"
	echo "- repo 				${ORANGE}: go to git repo URL${RESET}"
	echo "- branch 			${ORANGE}: go to git branch URL${RESET}"
	echo "- prs 				${ORANGE}: go to git repo Pull Requests URL${RESET}"
	echo "- actions 			${ORANGE}: go to git repo Actions URL${RESET}"
	echo "- issues 			${ORANGE}: go to git repo Issues URL${RESET}"
	echo "- notifs			${ORANGE}: go to git notifications URL${RESET}"
	echo "- profile			${ORANGE}: go to git profile URL${RESET}"
	echo "- org <myorg?>			${ORANGE}: go to git org URL${RESET}"
	echo "- help				${ORANGE}: go to wix-cli GitHub Pages URL${RESET}"
	echo ""
	sys.h1 "MY DATA:"
	echo "- user 				${ORANGE}: view your user-specific data (ie. name, GitHub username)${RESET}"
	echo "- myorgs 			${ORANGE}: view your GitHub organizations and their aliases${RESET}"
	echo "- mydirs 			${ORANGE}: view your directory aliases${RESET}"
	echo "- myscripts 			${ORANGE}: view your script aliases${RESET}"
	echo "- todo				${ORANGE}: view your to-do list${RESET}"
	echo ""
	sys.h1 "MANAGE MY DATA:"
	echo "- editd <data> 			${ORANGE}: edit a piece of your data (ie. user, myorgs, mydirs, myscripts, todo)${RESET}"
	echo "- edits <myscript> 		${ORANGE}: edit a script (you must use an alias present in myscripts)${RESET}"
	echo "- newscript <script-name?>	${ORANGE}: create a new script${RESET}"
	echo ""
	sys.h1 "ENV/KEYSTORE:"
	echo "- keystore <key> <value?>	${ORANGE}: add a key-value pair to your keystore${RESET}"
	echo "- setup openai_key		${ORANGE}: setup your OpenAI API key${RESET}"
	echo "- setup smart_commit		${ORANGE}: setup your smart commit${RESET}"
	echo ""
	sys.h1 "FILE UTILITIES:"
	echo "- fopen				${ORANGE}: open current directory in files application${RESET}"
	echo "- find \"<regex?>\"		${ORANGE}: find a file inside the current directory using regex${RESET}"
	echo "- regex \"<regex?>\" \"<fname?>\"	${ORANGE}: return the number of regex matches in the given file${RESET}"
	echo "- rgxmatch \"<regex?>\" \"<fname?>\"${ORANGE}: return the string matches of your regex in the given file${RESET}"
	echo "- encrypt <dirname|fname?>	${ORANGE}: GPG encrypt a file/directory (saves as a new .gpg file)${RESET}"
	echo "- decrypt <fname?>	${ORANGE}: GPG decrypt a file (must be a .gpg file)${RESET}"
	echo ""
	sys.h1 "NETWORK UTILITIES:"
	echo "- ip				${ORANGE}: get local and public IP addresses of your computer${RESET}"
	echo "- wifi				${ORANGE}: list information on your available wifi networks${RESET}"
	echo "- wpass				${ORANGE}: list your saved wifi passwords${RESET}"
	echo "- speedtest			${ORANGE}: run a network speedtest${RESET}"
	echo "- hardware-ports		${ORANGE}: list your hardware ports${RESET}"
	echo ""
	sys.h1 "IMAGE UTILITIES:"
	echo "- genqr <url?> <fname?>		${ORANGE}: generate a png QR code for the specified URL${RESET}"
	echo "- upscale <fname?> <scale?>	${ORANGE}: upscale an image's resolution (**does not smooth interpolated pixels**)${RESET}"
	echo ""
	sys.h1 "TEXT UTILITIES:"
	echo "- genpass <pass-length?>	${ORANGE}: generate and copy random password string (of default length 16)${RESET}"
	echo "- genhex <hex-length?>		${ORANGE}: generate and copy random hex string (of default length 32)${RESET}"
	echo "- genb64 <base64-length?>	${ORANGE}: generate and copy random base64 string (of default length 32)${RESET}"
	echo "- copy <string?|cmd?> 		${ORANGE}: copy a string or the output of a shell command (using \$(<cmd>) syntax) to your clipboard${RESET}"
	echo "- lastcmd			${ORANGE}: copy the last command you ran to your clipboard${RESET}"
	echo ""
	sys.h1 "WEB UTILITIES:"
	echo "- webtext <url?>		${ORANGE}: extract readable text from a website" 
	echo ""
	sys.h1	"MISC UTILITIES:"
	echo "- weather <city?>		${ORANGE}: get the weather forecast for your current location${RESET}"
	echo "- moon				${ORANGE}: get the current moon phase${RESET}"
	echo "- leap-year			${ORANGE}: tells you the next leap year"
	echo ""
	sys.h1 "HELP UTILITIES:"
	echo "- explain \"<cmd?>\"		${ORANGE}: explain the syntax of the input bash command${RESET}"
	echo "- ask-gpt			${ORANGE}: start a conversation with OpenAI's ChatGPT in the terminal${RESET}"
	echo "- google \"<query?>\"		${ORANGE}: google a query${RESET}"
	echo ""
}

# Source bash classes
source $(dirname ${BASH_SOURCE[0]})/src/classes/command/command.h


if [ $num_args -eq 0 ]; then
	# No input - show command info
	command_info

else
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
