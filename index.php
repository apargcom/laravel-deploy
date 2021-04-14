<?
set_time_limit(60);
if($_GET['pass'] == '') //Set password for accessing this URL
{
	$command = './deploy.sh' . ($_GET['force'] == 'true' ? ' -f' : '');
	echo '<pre>' . shell_exec($command) . '</pre>';
}