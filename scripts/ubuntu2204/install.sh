#!/bin/bash

SCRIPT_REL_PATH="wanderer-project/scripts/ubuntu2204/";

RUN_PATH=$(pwd);

relPath=$0;
relPath=${relPath:2};
relPath=${relPath/"install.sh"/""};
resultPath="$RUN_PATH/$relPath";

# shellcheck disable=SC2034
SCRIPT_PATH="$RUN_PATH/$relPath";

# load config vars
# shellcheck disable=SC1090
. "${SCRIPT_PATH}config.sh";

PROJECTS_PATH=${resultPath/$SCRIPT_REL_PATH/""};
PROJECT_FOLDER="$PROJECT_FOLDER";
PROJECT_PATH="$PROJECTS_PATH$PROJECT_FOLDER"
SERVER_PATH="$PROJECT_PATH/wanderer-server/";
CLIENT_PATH="$PROJECT_PATH/wanderer-client/";

echo "PROJECTS_PATH - $PROJECTS_PATH";
echo "SCRIPT_PATH - $SCRIPT_PATH";
echo "PROJECT_PATH - $PROJECT_PATH";
echo "SERVER_PATH - $SERVER_PATH";
echo "CLIENT_PATH - $CLIENT_PATH";

# Need to check and install postgresql
echo "Check and install Postgres";
checkPG=$(dpkg --list | grep postgresql);
if [ "$checkPG" == "" ]; then
  sudo apt install postgresql;
fi

# Check and install Bzip2
echo "Check and install Bzip2";
checkBzip2=$(dpkg --list | grep bzip2);
if [ "$checkBzip2" == "" ]; then
  sudo apt install bzip2;
fi

echo "Check and install Nodejs and npm";
checkNode=$(dpkg --list | grep checkNode);
if [ "$checkNode" == "" ]; then
  sudo apt install nodejs npm;
fi

echo "Check and install 'n' node version manager";
checkN=$(npm list --location=global | grep n@);
if [ "$checkN" == "" ]; then
  sudo npm install -g n;
fi;

# upgrade node to latest version
echo "upgrade node to latest version";
sudo n stable;
hash -r;

PG_USER_HOME=$(sudo -H -u postgres bash -c 'echo $HOME');

pgVersion=$(ls /usr/lib/postgresql/);
binaries="/usr/lib/postgresql/$pgVersion/bin";
pgInitFolder="$PG_USER_HOME/.postgresData";

rm -rf "$pgInitFolder";

echo "$binaries/initdb";
echo "$pgInitFolder";

# Initialize locale
sudo -u postgres -H "$binaries/initdb" --locale=en_US.UTF-8 -E UTF8 -D "$pgInitFolder";

# Will create new user and default dummy database (need for connect)
sudo -u postgres psql -c "create user ${SQL_User} with createrole createdb password '${SQL_Password}'";
sudo -u postgres psql -c "create database ${SQL_DB_DUMMY}";
sudo -u postgres psql -c "grant all privileges on database ${SQL_DB_DUMMY} to ${SQL_User}";


sudo rm -rf "$PROJECT_PATH";
mkdir -p "$PROJECT_PATH";
cd "$PROJECT_PATH" || exit;

# Installing server
echo "Installing server";

sudo rm -rf "$SERVER_PATH";
git clone https://github.com/DanSylvest/wanderer-server.git;

cd "$SERVER_PATH" || exit;

# Create custom config
echo 'Create custom server config'
echo "{
  \"connection\": {
    \"protocol\": \"${CN_Protocol}\",
    \"port\": ${CN_Port},
    \"ssl\": {
      \"key\": \"${CN_SSL_Key}\",
      \"cert\": \"${CN_SSL_Cert}\"
    }
  },
  \"db\": {
    \"names\": {
      \"mapper\": \"${SQL_DB_MAIN}\",
      \"eveSde\": \"${SQL_DB_EVE_STATIC_DATA}\",
      \"cachedESD\": \"${SQL_DB_CACHE}\"
    },
    \"user\": \"${SQL_User}\",
    \"password\": \"${SQL_Password}\",
    \"name\": \"${SQL_DB_DUMMY}\"
  },
  \"eve\": {
    \"app\": {
      \"client_id\": \"${EVE_CLIENT_KEY}\",
      \"secret_key\": \"${EVE_SECRET_KEY}\"
    }
  }
}" > "$SERVER_PATH/js/conf/custom.json";


echo "Download latest Eve static data database";
if [ "$(find eveData | grep dump)" == "" ]; then
  mkdir -p "$SERVER_PATH/eveData/dump";
fi

cd "$SERVER_PATH/eveData/dump" || exit;

latestURL='https://www.fuzzwork.co.uk/dump/latest/';
RX='postgres.*TRANQUILITY.dmp';
RXBZ="${RX}.bz2";
latestSDE=$(curl "${latestURL}" | grep -o "\"${RXBZ}\"" | grep -o "${RX}");
echo "Latest SDE ${latestSDE}";

isCurrentLatest=$(find . | grep -o "$latestSDE");
if [ "$isCurrentLatest" == "" ]; then
  echo "Start download \"${latestSDE}.bz2\""
  # shellcheck disable=SC2115
  rm -rf "${SERVER_PATH}/*";
  curl -O "${latestURL}/${latestSDE}.bz2";
  bzip2 -d "${latestSDE}.bz2";
fi

cd "$SERVER_PATH" || exit;

# Install server part
echo "Install server part";
npm install;
npm run installApp;

echo "Finished";

#git clone https://github.com/DanSylvest/wanderer-client.git


