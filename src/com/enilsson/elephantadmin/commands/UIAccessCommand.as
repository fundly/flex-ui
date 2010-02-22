package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.UIAccessDelegate;
	import com.enilsson.elephantadmin.events.UIAccessEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.UIAccessVO;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class UIAccessCommand extends SequenceCommand 
	{
		private var _model 		: EAModelLocator = EAModelLocator.getInstance();
		private var _event		: UIAccessEvent;
		
		private static var _logger : ILogger = Log.getLogger("UIAccessCommand");
		
		
		override public function execute( event : CairngormEvent) : void
		{
			_event = event as UIAccessEvent;
			if(! _event) return;
			
			switch(_event.type) {
				case UIAccessEvent.GET_UI_ACCESS_RIGHTS:
					getUIAccessRights();
				break;
				case UIAccessEvent.SET_UI_ACCESS_RIGHTS:
					setUIAccessRights();
				break;	
			}					
		}
		
		private function getUIAccessRights() : void {
			var delegate : UIAccessDelegate = new UIAccessDelegate( new Responder( handleGetUIAccessRightsResult, handleGetUIAccessRightsFault ) );
			delegate.getUIAccess( _event.userId );
			_model.dataLoading = true;
		}
		private function handleGetUIAccessRightsResult( event : ResultEvent ) : void {
			_model.uiAccess = event.result as UIAccessVO;
			_model.dataLoading = false;
			
			if(_event.nextEvent) {
				nextEvent = _event.nextEvent;
				executeNextCommand();
			}
		}
		private function handleGetUIAccessRightsFault( event : FaultEvent ) : void {
			var vo : UIAccessVO = new UIAccessVO();
			_model.uiAccess = vo;
			_model.dataLoading = false;
		}
		
		private function setUIAccessRights() : void {
			if( _event.vo == null ) return;
			
			var delegate : UIAccessDelegate = new UIAccessDelegate( new Responder( handleSetUIAccessRightsResult, handleSetUIAccessRightsFault ) );
			delegate.setUIAccess( _event.vo );
			_model.dataLoading = true;
			
			if(_event.nextEvent) {
				nextEvent = _event.nextEvent;
				executeNextCommand();
			}
		}
		private function handleSetUIAccessRightsResult( event : ResultEvent ) : void {
			_model.dataLoading = false;
		}
		private function handleSetUIAccessRightsFault( event : FaultEvent ) : void {
			_model.dataLoading = false;
		}
	}
}