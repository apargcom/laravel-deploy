#Branch to pull
BRANCH="master"
#Path to project
PROJECT_PATH="/home/apargcom/addon/ipsm"

#Deploy hook
function deploy(){
	# Turn on maintenance mode
	php artisan down || true
	
	# Discard all uncommited changes
	git reset --hard	
	
	# Remove all untracked files and folders
	git clean -df
	
	# Pull the latest changes from the git repository
	git pull origin $BRANCH

	# Install/update composer dependecies
	composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

	# Run database migrations
	php artisan migrate --force

	# Clear caches
	php artisan cache:clear

	# Clear expired password reset tokens
	php artisan auth:clear-resets

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

#Change umask to 022 for correct file permissions
umask 022

# Change to the project directory
cd $PROJECT_PATH

#Getting script flags
while getopts f FLAGS
do
    case "${FLAGS}"
    in
        f) FORCE="1";;
    esac
done

#Getting git hashes
HEAD_HASH=$(git rev-parse HEAD)
HASH_LENGTH=${#HEAD_HASH}
UPSTREAM_HASH=$(git ls-remote origin -h refs/heads/$BRANCH)
UPSTREAM_HASH=${UPSTREAM_HASH:0:HASH_LENGTH}

#Call deploy hook if meet the conditions
if [ "$HEAD_HASH" != "$UPSTREAM_HASH" ]  || [ "$FORCE" == "1" ]
then
	deploy
else
	echo "Not deployed. Already up-to-date."
fi
