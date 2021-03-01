#This method don't work because of OPCache. 
#Symlinks are being cached and even after change old php files are being served.

PROJECT_PATH="/home/awiam/sub/zero"
PROJECT_PUBLIC="/public"
DOMAIN_PUBLIC="/public"
DEPLOYS_PATH="/versions"
REPO="git@bitbucket.org:ARMEN97/awi.git"

#Project deploy hookPROJECT_PATH="/home/awiam/sub/zero"
PROJECT_PUBLIC="/public"
DOMAIN_PUBLIC="/public"
DEPLOYS_PATH="/versions"
REPO="git@bitbucket.org:ARMEN97/awi.git"

#Project deploy hook
function project_deploy(){

	# Turn on maintenance mode
	php artisan down || true

	# Pull the latest changes from the git repository
	# git reset --hard
	# git clean -df
	git pull origin master

	# Install/update composer dependecies
	composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
	
	# Create storage link
	rm -rf "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY$PROJECT_PUBLIC/storage"
	ln -sf "$PROJECT_PATH/storage" "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY$PROJECT_PUBLIC/storage"
	
	# Create .env link
	rm -rf "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY/.env"
	ln -sf "$PROJECT_PATH/.env" "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY/.env"

	# Run database migrations
	php artisan migrate --force

	# Clear caches
	php artisan cache:clear

	# Clear expired password reset tokens
	#php artisan auth:clear-resets

	# Clear and cache routes
	php artisan route:cache

	# Clear and cache config
	php artisan config:cache

	# Clear and cache views
	php artisan view:cache

	# Install node modules
	# npm ci

	# Build assets using Laravel Mix
	# npm run production

	# Turn off maintenance mode
	php artisan up
	
}

#Project init hook
project_init()
{
	git clone $REPO .
}

#Change umask to 022 for correct file permissions
umask 022

#Getting script flags
while getopts f FLAGS
do
    case "${FLAGS}"
    in
        f) FORCE="1";;
    esac
done

#Getting current deploy version folder
if [ -d "$PROJECT_PATH$DEPLOYS_PATH" ]
then
	if [ "$(readlink "$PROJECT_PATH$DOMAIN_PUBLIC")" == "$PROJECT_PATH$DEPLOYS_PATH/v_1$PROJECT_PUBLIC" ]
	then	
		CURRENT_DEPLOY="/v_2"
	else
		CURRENT_DEPLOY="/v_1"		
	fi	
else
	CURRENT_DEPLOY="/v_1"
fi

#If current deploy doesn't exsist init it
if [ ! -d "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY" ]
then
	FORCE="1"
	mkdir -p "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY"
	cd "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY"	
	project_init
fi

#Getting git hashes
cd "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY"
HEAD_HASH=$(git rev-parse HEAD)
HASH_LENGTH=${#HEAD_HASH}
UPSTREAM_HASH=$(git ls-remote origin -h refs/heads/master)
UPSTREAM_HASH=${UPSTREAM_HASH:0:HASH_LENGTH}

if [ "$HEAD_HASH" != "$UPSTREAM_HASH" ]  || [ "$FORCE" == "1" ]
then	
	project_deploy
	rm -rf "$PROJECT_PATH$DOMAIN_PUBLIC"	
	ln -sf "$PROJECT_PATH$DEPLOYS_PATH$CURRENT_DEPLOY$PROJECT_PUBLIC" "$PROJECT_PATH$DOMAIN_PUBLIC"
else
	echo "Not deployed. Already up-to-date."
fi
