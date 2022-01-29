### Deploy via ssh
1. Copy files to _public/deploy_ folder
2. To deploy run (use _-f_ flag to force deploy)
```
cd public/deploy

./deploy.sh
```
### Deploy via webhooks
1. Copy files to _public/deploy_ folder
2. Set password in _index.php_
3. Add webhook URL to repo settings _http://yourdomain.com/deploy?pass=YOUR_PASSWORD_