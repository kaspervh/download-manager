mapfile -t artists < <(jq -r 'keys[]' download-list.json)
json_file="$PWD"


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