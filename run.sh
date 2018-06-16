#!/bin/sh

images="cosmik/web:master cosmik/web_dev:master cosmik/tools:master cosmik/search:master cosmik/websocket:master cosmik/config"
base_images="ubuntu:16.04 elasticsearch:2 alpine crossbario/crossbar"


if [ $# -lt 1 ]; then
	echo "usage: $(basename "$0") command..."
	echo ""
	echo "Commands:"
	echo "  build    Build images"
	echo "  patches  Create patches from original and patched files"
	echo "  push     Push images to registry"
	echo "  rmi      Remove images"
	echo "  rmi-base Remove base images"
	echo "  up       Update (build and push) images"
	exit 1
fi

print() {
	if command -v tput > /dev/null; then
		color_default=$(tput sgr0)
		color_red=$(tput setaf 1)
		color_green=$(tput setaf 2)
		color_yellow=$(tput setaf 3)
		color_blue=$(tput setaf 4)
		color_white=$(tput setaf 7)
	fi

	case $1 in
		start)
			printf "%s%s%s" "${color_blue}" "$2" "${color_default}"
			if [ "$2" != "" ] && [ "$3" != "" ]; then
				printf " "
			fi
			echo "${color_yellow}$3${color_default}:"
		;;
		success)
			echo "${color_green}DONE: $2${color_default}"
		;;
		error)
			echo "${color_red}ERROR: $2${color_default}"
		;;
		*)
			eval "color=\${color_$1}"
			printf "%s%s%s" "${color}" "$2" "${color_default}"
		;;
	esac
}

field_position() {
	i=1
	for field in $2; do
		if [ "$1" = "$field" ]; then
			echo $i
			return 0
		fi
		i=$((i+1))
	done
	return 1
}

run_cmd() {
	print start "$1" "$2"

	if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
		print error "check parameters"
		return 1
	fi

	for field in $3; do
		if [ "$1" = "docker" ] && [ "$2" = "build" ]; then
			folder="$(dirname "$0")"
			$1 "$2" "--tag=$field" "-f=${field##*/}/Dockerfile" "$folder"
		elif [ "$1" = "docker" ] && [ "$2" = "push" ]; then
			$1 "$2" "$field"
		else
			$1 "$2" "$field" > /dev/null
		fi
		if [ $? -eq 0 ]; then
			print success "$2 $field"
		else
			print error "$2 $field failed"
		fi
	done

	echo ""
}

run_cmd_async() {
	print start "$1" "$2"

	if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
		print error "check parameters"
		return 1
	fi

	pids=""
	for field in $3; do
		$1 "$2" "$field" > /dev/null &
		pids="$pids $!"
	done

	for pid in $pids; do
		pos=$(field_position "$pid" "$pids")
		field_name=$(echo "$3" | cut -d " " -f "$pos")
		if wait "$pid"; then
			print success "$2 $field_name"
		else
			print error "$2 $field_name failed"
		fi
	done

	echo ""
}

while [ ! -z "$1" ]; do
	case $1 in
		build)
			run_cmd docker build "$images"
		;;
		patches)
			for dir in *; do
				if [ -d "$dir" ] && [ -d "$dir/original" ] && [ -d "$dir/patched" ]; then
					echo "creating patches for $dir"
					for file in $dir/original/*; do
						originalfile="$file"
						file="$(basename "$file")"
						patchedfile="$dir/patched/$file"
						if [ -f "$originalfile" ] && [ -f "$patchedfile" ]; then
							patchfile="$file.patch"
							diff "$originalfile" "$patchedfile" > "$dir/$patchfile"
							print success "$patchfile"
						else
							print error "$file mismatch"
						fi
					done
				fi
			done
		;;
		push)
			run_cmd docker push "$images"
		;;
		rmi)
			run_cmd_async docker rmi "$images"
		;;
		rmi-base)
			run_cmd_async docker rmi "$base_images"
		;;
		up)
			$0 build push
		;;
		*)
			print error "unknown command $1"
		;;
	esac
	shift
done

exit 0
