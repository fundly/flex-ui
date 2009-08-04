package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.events.GetVersionEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.popups.update.UpdateAvailableWindow;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class GetVersionCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model : EAModelLocator = EAModelLocator.getInstance();
		
		private static var _logger : ILogger = Log.getLogger("GetVersionCommand");
		
		override public function execute( event : CairngormEvent) : void
		{
			var e : GetVersionEvent = event as GetVersionEvent;
			if(e.nextEvent)
				this.nextEvent = e.nextEvent;
			
			var token : AsyncToken = ServiceLocator.getInstance().getHTTPService("versionService").send();
			token.addResponder(this);
		}
		
		public function result( data : Object ) : void
		{
			var versionXml : XML = data.result as XML;
			if(versionXml)
			{
				var remoteVersion : String	= versionXml.version;
				var remoteRevision : String	= versionXml.revision;
				
				if(_model.version == remoteVersion && _model.revision == remoteRevision)
				{
					if(nextEvent)
						executeNextCommand();
				}
				else
				{
					UpdateAvailableWindow.show();
				}
			}			
						
		}
		
		public function fault( info : Object ) : void
		{
			if(_model.debug) _logger.error(ObjectUtil.toString(info));
			
			// if the revision.xml is not present, carry on anyway.
			if(nextEvent)
				executeNextCommand();
		}

	}
}