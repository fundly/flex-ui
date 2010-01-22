package com.enilsson.elephantadmin.commands.modules.app_options
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.events.modules.app_options.SetShowStatsEvent;

	public class SetShowStatsCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var e : SetShowStatsEvent = event as SetShowStatsEvent;
			
			if(!e) return;
			
			switch( e.type ) {
				case SetShowStatsEvent.SHOW:
					save
				break;
				case SetShowStatsEvent.HIDE:
				break;
			}
		}
		
	}
}