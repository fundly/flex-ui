package com.enilsson.common.utils
{
	import mx.core.IToolTip;
	import mx.managers.ToolTipManager;
	
	public class TooltipUtil
	{
		public static function hideTooltip() : void {					
			var curTT : IToolTip = ToolTipManager.currentToolTip;
			try {
				ToolTipManager.destroyToolTip( curTT );
				ToolTipManager.currentToolTip = null;
			} catch( e : Error ) { trace(e.getStackTrace()); } 
		}
	}
}