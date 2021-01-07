GUIDE for developers (linux guide, examples will be for ArchLinux):

######## PREPARING SYSTEM #######
 before install server you MUST install next:
 - node (sudo pacman -S node)
 - npm (sudo pacman -S npm)
 - Git (sudo pacman -S git)
 - PostgreSQL (sudo pacman -S postgresql);

 OPTIONAL
 - yay (How to install yay - https://www.tecmint.com/install-yay-aur-helper-in-arch-linux-and-manjaro/)
 - omnidb (yay -S omnidb-app)
 - one of
   - lighttpd (sudo pacman -S lighttpd) # my choice (lighttpd.conf you can find next)
   - apache (sudo pacman -S apache)

 ===== Postgres PART
 ====================
 You must be sure that after postgres installation you can call psql

 It may help you - https://wiki.archlinux.org/index.php/PostgreSQL
 try it - if you see help - psql prepared for work
```
$ psql --help
```

 Switch to [postgres] user
```
$ su -l postgres
# OR
$ sudo -iu postgres
# OR
$ sudo su - postgres

```

 Init Postgres under [postgres] user
 With defaul locale
[postgres]$ initdb -D /var/lib/postgres/data

 Or with custom locale
[postgres]$ initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data

 Next we need add postgres to services
[postgres]$ sudo systemctl enable postgresql

 Next we need run service
[postgres]$ sudo systemctl start postgresql

 Next we check service (if ok - good. If not ok - start googling)
[postgres]$ sudo systemctl enable postgresql

 Next create PostgresSQL user [postgres]
[postgres]$ createuser postgres

 Last step create [mapper] database
[postgres]$ createdb -O postgres mapper

 We need check that database [mapper] has been created
[postgres]$ psql

 \l command show us all databases
postgres=# \l

# ==== OUTPUT
#
#                                       List of databases
#         Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
# ---------------------+----------+----------+-------------+-------------+-----------------------
#  mapper              | postgres | UTF8     | ru_RU.UTF-8 | ru_RU.UTF-8 | 

 exit from psql
postgres=# \q

 Exit from [postgres] user
[postgres]$ exit

 =======================
 ===== END Postgres PART


 Create your folder where will be placed project
 For example it may be /home/user/www/wanderer/ next - YOUR_FOLDER


############ Configuring HTTPS ###########
##########################################

 I generated free certificate here: https://freessl.space/
 Apache openssl How to: https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html

 Lighttpd instruction:
 1) Create Folder
$ mkdir -p /etc/lighttpd/keys && cd /etc/lighttpd/keys

 2) Create pem file for lighttpd
$ cat YOUR_HOST.key YOUR_HOST.crt > YOUR_HOST.pem

 3) Create Lighttpd config file

 Config usually placed here: /etc/lighttpd/lighttpd.conf
 This is a minimal example config
 See /usr/share/doc/lighttpd
 and http://redmine.lighttpd.net/projects/lighttpd/wiki/Docs:ConfigurationOptions
###############################################
############### lighttpd.conf #################
server.port             = 80
server.username         = "http"
server.groupname        = "http"
server.document-root    = "YOUR_FOLDER"
server.errorlog         = "/var/log/lighttpd/error.log"
dir-listing.activate    = "disable"
index-file.names        = ( "index.html" )
mimetype.assign         = (
                            ".html" => "text/html",
                            ".txt" => "text/plain",
                            ".css" => "text/css",
                            ".js" => "application/x-javascript",
                            ".jpg" => "image/jpeg",
                            ".jpeg" => "image/jpeg",
                            ".svg" => "image/svg+xml",
                            ".gif" => "image/gif",
                            ".png" => "image/png",
                            "" => "application/octet-stream"
                        )
# If you want use openssl uncomment mod_openssl
server.modules += ( 
    "mod_wstunnel", 
    "mod_access", 
    "mod_accesslog", 
    "mod_redirect", 
    "mod_rewrite", 
    "mod_userdir", 
#    "mod_openssl" 
)

# If you want use mod_openssl
# $SERVER["socket"] == "0.0.0.0:443" {
#    ssl.engine  = "enable"
#    ssl.pemfile = "/etc/lighttpd/keys/YOUR_PEMFILE.pem"
# }

$HTTP["host"] == "YOUR_HOST" {
    server.document-root = "YOUR_FOLDER/wanderer-client/dist"

# If you want use mod_openssl you need uncomment it
#    $HTTP["scheme"] == "http" {
#        url.redirect = ("^/(.*)" => "https://YOUR_HOST/$1")
#    }
}
############## LIGHTTPD config ################
###############################################


############ INSTALLING ###############
#######################################

 So, now we ready for instal Wanderer server
$ cd YOUR_FOLDER


 ==== SERVER
 ===========
 First - you need clone server repo
$ git clone https://github.com/DanSylvest/wanderer-server

 ALSO you need check EVE DATABASE DUMP here: https://www.fuzzwork.co.uk/dump/
 you need download actual DB
 - find last folder which looks like [sde-xxxxxxxx-TRANQUILITY] and open it
 - find file looks like [postgres-xxxxxxxx-TRANQUILITY.dmp.bz2]
 - where xxxxxxxx is date
 - download it
 - go into download folder and decompress it
$ bzip2 -dk postgres-xxxxxxxx-TRANQUILITY.dmp.bz2

 next you should copy or move [postgres-xxxxxxxx-TRANQUILITY.dmp] into: YOUR_FOLDER/wanderer-server/js/db/sdeDump
 also you MUST remove old dump

 we need download node_modules for project so:
$ npm install

 also we MUST install wanderer server (this is not fast process)
$ cd YOUR_FOLDER/wanderer-server/
$ npm run installApp

 If installation done - it's all

####### CONFIGURING
 Before start server and client you sould configurate server and client config.

####### CREATE CCP APPLICATION for API Access
 0) Go here: https://developers.eveonline.com/applications
 1) Create new app, fill Name and Description
 2) Select type "Authentication & API Access"
 3) Permissions: you MUST set next scopes:
     - esi-location.read_location.v1
     - esi-location.read_ship_type.v1
     - esi-ui.write_waypoint.v1
     - esi-location.read_online.v1
 4) Callback URL:
     Template of callback <PROTOCOL>://<HOST>/?page=ssoAuth
     Example: http://yourHostName.com/?page=ssoAuth
     Protocol can be http or https
 5) Create server config:
 It should be placed in: YOUR_FOLDER/wanderer-server/js/conf;
 Copy Client ID and Secret Key from your CCP Application and fill empty fields
############### custom.json #############
{
	"eve": {
		"app": {
			"client_id": "",
			"secret_key": ""
		}
	}
}
############### custom.json #############
 6) Create client config:
 It should be placed in: YOUR_FOLDER/wanderer-client/src/conf;
############### custom.js #############
module.exports = {
    eve: {
        sso: {
            client: {
                client_id: "", // application Client Id,
            }
        }
    }
};
############### custom.json #############


##### Setting SSL 
 If you want use HTTPS protocol you need configuring server config.
 Example
 Because i using lighttpd - my keys placed here: /etc/lighttpd/keys, but it optional
############### custom.json ##############
{
    "eve": {
        "app": {
            "client_id": "YOUR_CCP_CLIENT_ID",
            "secret_key": "YOUR_CCP_SECRECT_KEY"
        },
        "password": ""
    },
    "connection": {
        "protocol": "https",
        "port": 1400,
        "ssl": {
            "key": "PATH_TO_YOUR_SSL_KEY/YOUR_HOST.key",
            "cert": "PATH_TO_YOUR_SSL_KEY/YOUR_HOST.crt"
        }
    }
}
############### custom.json ##############




# ==== CLIENT
# ===========
$ cd YOUR_FOLDER
$ git clone https://github.com/DanSylvest/wanderer-client
$ cd YOUR_FOLDER/wanderer-client/
$ npm install 

it's all :)
===============


 How to start server:
$ cd YOUR_FOLDER/wanderer-server/
$ npm run dev


 How to start client on develop server
$ cd YOUR_FOLDER/wanderer-client/
$ npm run serve

 OR if you want build
 Then files will be in directory [YOUR_FOLDER/wanderer-client/dist]
```
$ npm run buildDev
```