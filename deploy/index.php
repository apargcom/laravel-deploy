<?

if($_GET['pass'] == 'wdeDReEe8tNAJWY6wCT9')
{
	$command = $_GET['force'] == 'true' ? './deploy.sh -f' : './deploy.sh';
	echo '<pre>' . shell_exec($command) . '</pre>';
}