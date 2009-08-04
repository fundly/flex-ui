package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.SearchEvent;
	
	import org.osflash.thunderbolt.Logger;
	
	public class SearchCommand implements ICommand
	{			
		public function execute(e:CairngormEvent):void
		{			
			var event : SearchEvent = e as SearchEvent;
			
			try {
				new SearchDelegate(event.responder).search(event.search);
			}
			catch ( e  : Error ) { }
		}	
	}
}