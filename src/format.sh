#!/usr/bin/bash

WORKDIR=pages

function next_num() {
  NUM=$(bc <<< "$(ls $WORKDIR | wc -l) + 1")
  echo "$NUM"
}

function simple_note() {
  NAME="$*"
  CAMEL_NAME=$(to_camelcase "$NAME")
	FILE_NAME=$(find ./$WORKDIR -name "*_$CAMEL_NAME.md" | head -n 1)

	if [ ! -z "$FILE_NAME" ]; then
		echo "$FILE_NAME"
	else
    NUM=$(bc <<< "$(ls $WORKDIR | wc -l) + 1")

    NEW_FILE="$WORKDIR/$NUM"_"$CAMEL_NAME.md"

    echo "# $(sed 's/^./\U&/' <<< $NAME)" > $NEW_FILE
    echo $NEW_FILE
  fi
}

function daily_note() {
	# if file with current date exists
	#	then return its name
	# else
	#	1. Ask for a tag and set name
	#	2. Touch file
	#	3. Fill the file with template
	#	4. Return the name
	CURRENT_DATE=$(date "+%a%d-%b-%y")
	TODAY_FILE=$(find ./$WORKDIR -name "*_$CURRENT_DATE*.md" | head -n 1)

	if [ ! -z "$TODAY_FILE" ]; then
		echo "$TODAY_FILE"
	else
		# echo -n "Set a tag for the file: "
		# read TAG
		# echo "tag: $TAG"
    NUM=$(bc <<< "$(ls $WORKDIR | wc -l) + 1")
		FILE_NAME="$WORKDIR/$NUM"_"$CURRENT_DATE.md"
		echo "# $(date '+%A %d/%B/%y'):" > "./$FILE_NAME"
		echo "$FILE_NAME"
	fi
}

function remove_name() {
	# For files in ./$WORKDIR
	#       Store $num and $name
	#       Append "$num $name" to titles.txt
	#       Rename file as $num.md

	for file_name in $(ls $WORKDIR); do
		num=$(echo $file_name | sed -n 's/\([0-9]*\)_.*$/\1/p')
		name=$(echo $file_name \
			| sed -n 's/[0-9]*_\(\S*\)\.md$/\1/p')

		grep -qF "$num $name" src/titles.txt 2>&1
		if [ $? -ne 0 ]; then # Add if doesn't exist
			echo "$num $name" >> src/titles.txt
      echo "- [$name]($name)" >> SUMMARY.md
		fi
		if [ -n "$num" ]; then # Move if not null
			mv $WORKDIR/"$file_name" $WORKDIR/$num.md
		fi
	done
}

function restore_name() {
	# Rename all files as $num_$name.md
	for file_name in $(ls $WORKDIR); do
		num=$(echo $file_name | sed -n 's/\([0-9]*\)\.md$/\1/p')
		name=$(grep -w "$num" src/titles.txt | awk '{ print $2 }')

		if [ -n "$num" ] && [ -n "$name" ]; then
			mv $WORKDIR/"$num".md $WORKDIR/"$num"_"$name".md
		fi
	done
}

function to_camelcase() {
  # spaces to underscores
  # phrase to lowercase
  # first letter of each word to uppercase
  # remove underscores

  echo "$1" \
    | tr ' ' '_' \
    | tr '[:upper:]' '[:lower:]' \
    | sed -r 's/(^|_)([a-z])/\U\2/g'
}
