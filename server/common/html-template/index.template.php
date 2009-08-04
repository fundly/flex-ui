<?
error_reporting(0);

// set which app is called the config
$app = end( explode('/', pathinfo(__FILE__, PATHINFO_DIRNAME) ) ) == 'admin' ? 'admin' : '';

include( ($app == 'admin' ? '../' : '') . 'config.php' );
?>

<!-- saved from url=(0014)about:internet -->
<html lang="en">

<!-- 
Smart developers always View Source. 

This application was built using Adobe Flex, an open source framework
for building rich Internet applications that get delivered via the
Flash Player or to desktops via Adobe AIR. 

Learn more about Flex at https://flex.org 
// -->

<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!--  BEGIN Browser History required section -->
<link rel="stylesheet" type="text/css" href="<?= $siteURL ?>history/history.css" />
<!--  END Browser History required section -->

<link rel="shortcut icon" href="<?= $baseURL ?>images/blueswarm_favicon_large.png" />

<title><?= $flashvars['siteTitle'] ?></title>

<script src="<?= $siteURL ?>AC_OETags.js" language="javascript"></script>
<script src="<?= $siteURL ?>history/history.js" language="javascript"></script>

<style>
	body { margin: 0px; overflow:hidden }
	
	.noScriptWarning {
		width: 100%;
		background: #ff3300;
		color: #fff;
		text-align: center;
		margin: 0px;
		padding:20px 0;
	}
	.noScriptWarning p {
		margin: 0px;
		font-family: "Lucida Grande", Verdana;
		font-size: 14px;
	}
</style>
<script language="JavaScript" type="text/javascript">
<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 9;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 28;
// -----------------------------------------------------------------------------
// -->
</script>
<base href="<?= $siteURL ?>" />
</head>

<body scroll="no">

<?php
/*
<!--[if lte IE 6]> 
<div class="noScriptWarning">
	<p>There is currently a known bug with IE6 and secure connections that is preventing BlueSwarm from operating. We apologise for the inconvenience and we are working on fixing this, in the meantime please use another browser such as IE7 or any version of Firefox.</p>
</div>
<![endif]-->
*/
?>

<script language="JavaScript" type="text/javascript">
<!--
// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var hasProductInstall = DetectFlashVer(6, 0, 65);

// Version check based upon the values defined in globals
var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);

if ( hasProductInstall && !hasRequestedVersion ) {
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;

	AC_FL_RunContent(
		"src", "playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "<?= $width ?>",
		"height", "<?= $height ?>",
		"align", "middle",
		"id", "<?= $flexApplication ?>",
		"quality", "high",
		"bgcolor", "<?= $bgColor ?>",
		"flashvars", "<?= $flashVarsString ?>",
		"name", "<?= $flexApplication ?>",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "https://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "<?= $flexApplication ?>?revision=#REVISION#",
			"width", "<?= $width ?>",
			"height", "<?= $height ?>",
			"align", "middle",
			"id", "<?= $flexApplication ?>",
			"quality", "high",
			"bgcolor", "<?= $bgColor ?>",
			"flashvars", "<?= $flashVarsString ?>",
			"name", "<?= $flexApplication ?>",
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "https://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'This fundraising tool requires the Adobe Flash Player. '
   	+ '<a href=https://www.adobe.com/go/getflash/>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }
// -->
</script>
<noscript>
	<div class="noScriptWarning">
		<p>This fundraising tool requires javascript to run effectively, please turn it on otherwise you will be unable to proceed!</p>
	</div>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="<?= $flexApplication ?>" width="<?= $width ?>" height="<?= $height ?>"
			codebase="https://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="<?= $flexApplication ?>.swf?revision=#REVISION#" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="<?= $bgColor ?>" />
			<param name="flashvars" value="<?= $flashVarsString ?>">
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="<?= $flexApplication ?>.swf?revision=#REVISION#" quality="high" bgcolor="<?= $bgColor ?>"
				width="<?= $width ?>" height="<?= $height ?>" name="<?= $flexApplication ?>" align="middle"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				pluginspage="https://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>
</body>
</html>
