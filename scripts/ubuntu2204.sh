# GUIDE how Dan installed environment for Mapper on Ubuntu 22.04 (under Windows)

# update your distributive
sudo apt install postgresql;

# switch to postgres user
sudo -i -u postgres;

# Also you need check your postgres version
ls -al /usr/lib/postgresql/;

# And after set your version...
export PATH="/usr/lib/postgresql/14/bin:$PATH";

# for me - this is terrible horror part - because setting it up was with problems!
# i do not know why... but ahhh... hate it!!
initdb -D ~/data;

# Then enable and start service
# And i using this solve!
# Look for more info - https://askubuntu.com/questions/1379425/system-has-not-been-booted-with-systemd-as-init-system-pid-1-cant-operate
sudo service postgresql on;
sudo service postgresql start;

# Ok... create the data base
createdb -O postgres mapper
