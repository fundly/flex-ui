package com.enilsson.elephanttrakker.utils
{
	import flash.display.DisplayObject;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class AppUtils
	{
		public function AppUtils()
		{
		}
		
		/**
		 * Generic popup handling function
		 */
		public static function launchPopUp(popup:Class, parent:DisplayObject):void
		{
		 	var p:* = PopUpManager.createPopUp( parent, popup, true );

		    p.addEventListener(CloseEvent.CLOSE, function(e:Object):void{
		    	PopUpManager.removePopUp(p);
		    });
		    
		    PopUpManager.centerPopUp(p);
		}

	}
}