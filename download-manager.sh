mapfile -t artists < <(jq -r 'keys[]' download-list.json)

for i in ${artists[@]}; do 
	cd ~/Music/
	if [ -d "$i" ]; then
		echo directory $i exists
	else
		mkdir $i
		cd $i
		mapfile -t albums < <(jq -r --args "$i" '.[artist][] | keys[]' download-list.json)

		echo " $albums[@] "
	fi
	
done