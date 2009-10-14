package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.asual.swfaddress.SWFAddress;
	import com.enilsson.elephantadmin.events.main.ViewStateEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.containers.ViewStack;
	
	import org.osflash.thunderbolt.Logger;

	public class ViewStateCommand implements ICommand
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function ViewStateCommand()
		{
		}

		public function execute(event:CairngormEvent):void
		{
			// cast the Cairngorm event as a ViewStateEvent
			var e:ViewStateEvent = event as ViewStateEvent;
			// grab the viewstack as a variable from the event
			var vstack:ViewStack = e.viewstack;
			// set the deeplinking
			SWFAddress.setValue(_model.viewStateList[vstack.selectedIndex]);
			SWFAddress.setTitle(_model.appName + ' - ' + _model.viewStateNames[vstack.selectedIndex]);	
			
			if(_model.debug) Logger.info('ViewState Change', _model.viewStateList[vstack.selectedIndex]);			
		}
		
	}
}