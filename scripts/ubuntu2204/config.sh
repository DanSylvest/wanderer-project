#!/bin/bash

prefix='local';
PROJECT_FOLDER="$prefix";

# database part
SQL_DB_DUMMY='dummy';
SQL_DB_MAIN="${prefix}_wanderer";
SQL_DB_CACHE="${prefix}_wanderer_cache";
SQL_DB_EVE_STATIC_DATA="${prefix}_ESD";

SQL_Host='localhost';
SQL_Port='5432';
SQL_User="${prefix}_wanderer_user";
SQL_Password='Pwd1234';

CN_Port='1400';
CN_Protocol='http';
CN_SSL_Key='';
CN_SSL_Cert='';


EVE_CLIENT_KEY="ff0a41baabfc4349bf5880a881baaef5";
EVE_SECRET_KEY="QCINZlHBas3fVoLrYEqJ8jH1XHDluanVwikDMsdA";


