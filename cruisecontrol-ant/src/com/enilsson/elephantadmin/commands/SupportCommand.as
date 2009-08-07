package com.enilsson.elephantadmin.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.events.main.SupportEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephanttrakker.business.SupportDelegate;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class SupportCommand implements ICommand
	{
		private var _model:EAModelLocator = EAModelLocator.getInstance();

		public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('SupportCommand', ObjectUtil.toString(event.type)); }
			
			switch(event.type) {			
				case SupportEvent.EVENT_SEND_SUPPORT :
					doSupport(event as SupportEvent);
				break;
			}
		}
		
		/**
		 * make a support call
		 */
		private function doSupport(event:SupportEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_doSupport, onFault_doSupport);
			var delegate:SupportDelegate = new SupportDelegate(handlers);
			
			_model.dataLoading = true;
			
			delegate.doSupport( event.params );
		}

		private function onResults_doSupport(data:Object):void 
		{
			if(_model.debug){ Logger.info('Support Success', ObjectUtil.toString(data.result)); }

			_model.dataLoading = false;
	
			if(data.result.error == 1)	
			{
				_model.errorVO = new ErrorVO( 
					'There was a problem processing this ticket', 
					'errorBox', 
					true 
				);
			} 
			else 
			{
				_model.errorVO = new ErrorVO( 'Your ticket has been opened successfully', 'successBox', true );
			}			
		}	

		private function onFault_doSupport(data:Object):void
		{
			if(_model.debug){ Logger.info('Support Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}
	}
}