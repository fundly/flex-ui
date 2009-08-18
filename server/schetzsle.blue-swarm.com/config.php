<?php

/**
* Set the Client and Admin flex configurations
*/

// set the name of the swf
$flexApplication = $app == 'admin' ? 'ET_admin' : 'ET_cairngorm';

// set the base url for the app
$baseURL = 'https://schetzsle.blue-swarm.com/';

// set the site url for the app
$siteURL = $baseURL . ($app == '' ? '' : $app . '/');

// flash var options to pass into the application
$flashvars = array (
	'siteTitle' 	=> 'BlueSwarm',
	'authURL' 		=> 'https://client1-auth.blue-swarm.com/amfphp/gateway.php',
	'siteURL' 		=> $siteURL,
	'baseURL' 		=> $siteURL,
	'instanceID' 	=> 24,
	'clientUI'		=> $baseURL,
	'adminUI'		=> $baseURL . 'admin/',
	'orgLogo' 		=> $baseURL . 'images/logo.jpg',
	'orgName'		=> 'The Schetzsle Committee',
	'orgURL'		=> 'http://www.votebrett2010.com',
	'appLogo'		=> $baseURL . 'images/BlueSwarm_logo_noicon.png',
	's3URL'			=> 'https://trakker.s3.amazonaws.com/'
);

// turn the flashvars array into to a key/pair string
foreach($flashvars as $key=>$value)
	$flashVarsString .= '&' . $key . '=' . $value;

// some styling options
$height = '100%';
$width = '100%';
$bgColor = '#000000';


/**
* Set some configuration on for the standalone donation page
*/
$donationWidget = array (
	'css'			=> 'default.css',
	'height'		=> '1375',
	'width'			=> '870',
	'background'	=> '#FFFFFF',
	'mastheadImg'	=> 'logo_large.jpg'
)


?>