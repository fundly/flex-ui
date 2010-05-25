package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.events.main.SidEvent;
	import com.enilsson.elephantadmin.events.main.SidForIdEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class SidForIdCommand extends SequenceCommand
	{
		private var _model :EAModelLocator = EAModelLocator.getInstance();
		private var _event : SidForIdEvent;
		
		override public function execute(event:CairngormEvent):void {
			_event = event as SidForIdEvent;
			getSidForId();
		}
		
		private function getSidForId() : void {
			var handlers:IResponder = new mx.rpc.Responder(onResult_getSidForId, onFault_getSidForId);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getSid( _event.table, _event.recordId );		
		}
		
		private function onResult_getSidForId( event : ResultEvent ) : void {
			_model.dataLoading = false;
			
			nextEvent = new SidEvent( event.result as String );
			executeNextCommand();
			nextEvent = null;
		}
		private function onFault_getSidForId( event : FaultEvent ) : void {
			_model.dataLoading = false;
			
			if(_model.debug) Logger.error( "Error in SidForIdCommand.getSidForId: " + ObjectUtil.toString( event.fault ) );
		}
	}
}