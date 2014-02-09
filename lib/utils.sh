#!/usr/bin/env bash

# generic variables
VERSION="0.0.1"
BASE_DIR="$HOME/.msvm"
BASE_URL="http://s3.amazonaws.com/Minecraft.Download/versions"

# versions meta
VERSIONS_URL="$BASE_URL/versions.json"
VERSIONS_FILE="$BASE_DIR/versions.json"


#
# Print a log message
#
# @param type
# @param message
#
log() {
  printf "  \033[36m%10s\033[0m : \033[90m%s\033[0m\n" $1 $2
}

#
# Print an error message and exit
#
# @param message
#
error() {
  printf "  \033[31m%10s\033[0m : $@\n" "error" && exit 1
}

#
# Create dir if it does not exist
#
# @param dir
#
create_dir() {
  if [ ! -d $1 ]; then
    log "mkdir" $1
    mkdir -p $1
  fi
}

#
# Download a given URL, dump the headers and save the Etag
#
# @param url
# @param destination
#
download_save_etag() {
  local headers=$(mktemp)
  local base=$(drop_extension $2)

  create_dir $(dirname $2)              # create destination dir

  log "download" $1
  curl -s -D $headers -q $1 > $2        # download file & dump headers to tmp
  test $? != 0 && error "download failure"
  log "created" $2
  extract_etag $headers > ${base}.etag  # extract the ETag header
  echo $1 > ${base}.url                 # save the URL
  rm $headers                           # clean up the tmp file
}

#
# Extract ETag from HTTP response headers
#
# @param path
#
extract_etag() {
  cat $1 | egrep "^ETag" | cut -d'"' -f2
}

#
# Convert a file path into an equivalent one for storing the etag (basically
# swapping the extension for .etag)
#
# @param path
#
drop_extension() {
  local ext=$(echo $1 | awk -F . '{print $NF}')  # extract the extension
  echo $(dirname $1)/$(basename $1 .$ext)        # echo w/o ext
}

#
# Check if a file has been updated (via url/etag)
#
# @param file
#
is_updated() {
  local base=$(drop_extension $1)
  local etag=$(cat ${base}.etag)
  local url=$(cat ${base}.url)

  # attempt HEAD request, sending ETag
  local status=$(curl -s -I -H "If-None-Match: $etag" -w '%{http_code}' -o /dev/null $url)

  # HTTP 304 Not Modified
  if [ $status == "304" ]; then
    return 1  # indicate an "error"
  else
    log "updated" $url
  fi
}

#
# Download a file (only if the ETag has changed)
#
# @param file
#
download_if_updated() {
  local base=$(drop_extension $1)
  local url=$(cat ${base}.url)

  if [ -e $1 ]; then
    if is_updated $1; then
      download_save_etag $url $1
    fi
  else
    download_save_etag $url $1
  fi
}

#
# Generate the URL for a given minecraft server jar
#
# @param version
#
jar_url() {
  echo "$BASE_URL/$1/minecraft_server.$1.jar"
}

#
# Generate the path for a given minecraft server jar
#
# @param version
#
jar_path() {
  echo "$BASE_DIR/jars/$1/minecraft_server.jar"
}

#
# Check if the specified version has been installed
#
# @param version
#
is_installed() {
  if [ ! -f $(jar_path $1) ]; then
    return 1
  fi
}

#
# Get the id of the latest version for a specific type
#
# @param type
#
latest_version() {
  cat $VERSIONS_FILE | jq -c -r ".latest.$1"
}


# download version list if doesn't exist
if [ ! -e $VERSIONS_FILE ]; then
  download_save_etag $VERSIONS_URL $VERSIONS_FILE
fi
