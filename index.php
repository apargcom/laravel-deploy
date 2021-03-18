<?

if($_GET['pass'] == '') //Set password for accessing this URL
{
	$command = $_GET['force'] == 'true' ? './deploy.sh -f' : './deploy.sh';
	echo '<pre>' . shell_exec($command) . '</pre>';
}