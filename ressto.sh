#!/bin/bash

# set some global default values
version="0.0.1"
isResstoFolder=0
base=""
selectedId=-1
personId=-1
sourceId=-1

# initalize programm
InitProgramm(){
	IsResstoFolder
	if [ $isResstoFolder -eq 0 ]; then
		printf "Is not an ressto project. Aborting.\n"
		exit
	fi
	base=$(ReadJson "base")
	GetType
}

# Creates the neccessary file and folders
InitProject(){
	IsResstoFolder
	if [ $isResstoFolder -eq 1 ]; then
		printf "Is already a ressto project. Not initalized.\n"
		exit
	fi
	

	mkdir "sources"
	mkdir "persons"
	mkdir "bin"

	printf "$(CreateBasicJson "base" "./")" > .ressto
	printf "$(CreateBasicJson "sources" "../")" > sources/.ressto 
	printf "$(CreateBasicJson "persons" "../")" > persons/.ressto 
	

	touch persons/.list
	touch sources/.list

	local base=$(realpath .)
	printf "#!/bin/bash\nexport RESSTO=ressto\nexport base=$base\n" > bin/activate
	chmod +x bin/activate

	printf "#!/bin/bash\nunset RESSTO\nunset base\n" > bin/deactivate
	chmod +x bin/deactivate

	printf "Project initalized\n"
}

# Checks if the folder is a ressto folder
IsResstoFolder(){
	if [ -e ".ressto" ]; then
		isResstoFolder=1	
	fi
}

# reads a value to a key ($1)
ReadJson(){
	local value=$(grep -e "\"$1\" :" .ressto | grep -oe ": \".*\"" | cut -c4- | sed "s/\"//")
	printf "$value"
}

# creates a basic json file with a version, type and base
CreateBasicJson(){
	printf "$(CreateJson "version" $version "type" $1 "base" $2)"
}

# creates a json layout
CreateJson(){
	local json="{\n"
	local first=true
	while [[ $# -gt 1 ]]; do
		if [ $first = true ]; then
			first=false
		else
			json="$json,\n"
		fi
		key="$1"
		value="$2"
		json="$json\t\"$key\" : \"$value\""	
		shift
		shift
	done
	json="$json\n}\n"

	printf "$json"
}

# reades the type from a json
GetType(){
	type=$(ReadJson "type")
}

# generate a random id
RandomId(){
	local value=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 16)
	printf "$value"
}

# add a new source with a short handle
AddSource(){
	if [ -z "$1" ]; then
		printf "Handle as argument required.\n"
		exit
	elif [ -z "$2" ]; then
		printf "Url as argument required.\n"
		exit
	fi	
	local handle=$1
	local url=$2
	local date=$(date +%Y-%m-%d %H:%M:%S)
	local id=$(RandomId)
	local dir="sources"
	local path=$base$dir/$id
	
	mkdir "$path"
	mkdir "$path/persons"
	mkdir "$path/images"
	mkdir "$path/documents"

	printf "$(CreateJson "version" $version "type" "source" "base" "../../" "handle" "$handle")" > $path/.ressto 
	printf "$(CreateJson "url" "$url" "date" "$date")" > $path/info.json 
	printf "$(CreateBasicJson "source-persons" "../../../")" > $path/persons/.ressto 
	printf "$(CreateBasicJson "source-images" "../../../")" > $path/images/.ressto
       	printf "$(CreateBasicJson "source-documents" "../../../")" > $path/documents/.ressto printf "Created source: $id"

	printf "$id:$handle\n" >> $base$dir/.list

	printf "Source added: $id\n"
	
}

# add a new person with a short handle
AddPerson(){
	if [ -z "$1" ]; then
		printf "Handle as argument required.\n"
		exit
	fi	
	local handle=$1
	local id=$(RandomId)
	local dir="persons"
	local path=$base$dir/$id

	mkdir "$path"
	mkdir "$path/links"
	mkdir "$path/images"
	mkdir "$path/docs"


	printf "$(CreateJson "version" $version "type" "person" "base" "../../" "handle" "$handle")" > $path/.ressto 
	printf "$(CreateBasicJson "person-links" "../../../")" > $path/links/.ressto 
	printf "$(CreateBasicJson "person-documents" "../../../")" > $path/docs/.ressto 
	printf "$(CreateBasicJson "person-images" "../../../")" > $path/images/.ressto 

	printf "$id:$handle\n" >> $base$dir/.list

	printf "Person added: $id\n"
}

# link a file to something
Link(){
	file=$1
	if [[ $type = "source-persons" ]]; then
		LinkToPerson "$file" "links"
	elif [[ $type = "source-images" ]]; then
		LinkToPerson "$file" "images"
	fi

}

# link a file to a person
LinkToPerson(){
	local file=$1
	local folder=$2
	ChoosePerson
	
	local dir="persons"
	local id=$(RandomId)

	sourceId=$(basename $(realpath ../))
	cd $base$dir/$personId/$folder
	ln -s ../../../sources/$sourceId/persons/$file $id.ln
	cd $base
}

# open a choose person dialog
ChoosePerson(){
	Choose "persons/.list" "Choose a person: "
	personId="$selectedId"
}

# open a choose source dialog
ChooseSource(){
	Choose "sources/.list" "Choose a source: "
	sourceId="$selectedId"
}

# open a choose dialog
Choose(){
	local path=$1
	local i=0
	# show the user a list of handles
	while read -r line; do
		handle=$(echo $line | cut -d: -f2)
		printf "[$i] $handle\n"
		i=$(( $i + 1 ))
	done < $base$path
	printf "\n"

	read -p "$2" selected	

	# associate the given number to a id
	local j=0
	local id=-1
	while read -r line; do
		if [ $j = "$selected" ]; then
			id=$(echo $line | cut -d: -f1)
			break
		fi
		j=$(( $j + 1 ))
	done < $base$path

	selectedId="$id"
	if [ "$selectedId" = -1 ]; then
		printf "Given number does not exist.\n"
		exit
	fi
}

# find the id to a person
FindPerson(){
	ChoosePerson
	printf "Person id: $personId\n"
}

# find the id to a source
FindSource(){
	ChooseSource
	printf "Source id: $sourceId\n"
}

# init project if not given
if [ "$1" = "init" ]; then
	InitProject
fi


InitProgramm
# add
if [[ "$1" == *"a"* ]]; then
	# source
	if [[ "$1" == *"s"* ]]; then
		AddSource $2 $3
	# person
	elif [[ "$1" == *"p"* ]]; then
		AddPerson $2
	fi
# find
elif [[ "$1" == *"f"* ]]; then
	# source
	if [[ "$1" == *"s"* ]]; then
		FindSource 
	# person
	elif [[ "$1" == *"p"* ]]; then
		FindPerson
	fi
# link
elif [[ "$1" == *"l"* ]]; then
	Link "$2"
fi


