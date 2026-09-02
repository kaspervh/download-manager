mapfile -t artists < <(jq -r 'keys[]' download-list.json)
json_file="$PWD"

if ! command -v jq >/dev/null 2>&1; then
	echo ERROR jq not installed, please insall it with the following commands
	echo sudo apt update
	echo sudo apt install -y jq
	exit 1
fi 

if ! command -v yt-dlp >/dev/null 2>&1; then
	echo ERROR yt-dlp not installed, please install it with the following commands
	echo sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
	echo sudo chmod a+rx /usr/local/bin/yt-dlp
fi


#loops over each artist in order to create folders  
for i in ${artists[@]}; do 
	cd ~/Music/
	if [ -d "$i" ]; then
		echo directory $i exists
	else
		echo making directory for artist $artist
		mkdir $i
		cd $i
		mapfile -t albums < <(jq -r --arg artist "$i" '.[$artist][] | keys[]' $json_file/download-list.json )

		for album in ${albums[@]}; do
			echo "making folder for album $album"
			mkdir $album

			cd $album

			link=$(jq -r --arg artist "$i" --arg album "$album" '.[$artist][] | .[$album] // empty' "$json_file/download-list.json")

			echo downloading songs for album $album with playlist link $link

			yt-dlp -x --audio-format mp3 --audio-quality 0 \
			  --cookies-from-browser chrome \
			  -o "%(playlist_index)s - %(title)s.%(ext)s" \
			  "$link"
			cd ..
		done
	fi
	
done