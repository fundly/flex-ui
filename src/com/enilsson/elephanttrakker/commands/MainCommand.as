package com.enilsson.elephanttrakker.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.*;
	import com.enilsson.elephanttrakker.events.main.*;
	import com.enilsson.elephanttrakker.events.modules.call_logging.*;
	import com.enilsson.elephanttrakker.events.modules.overview.*;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class MainCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MainCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('Main Command', ObjectUtil.toString(event.type)); }
			
			switch(event.type)
			{			
				case SupportEvent.EVENT_SEND_SUPPORT :
					doSupport(event as SupportEvent);
				break;
				case GetRSSEvent.EVENT_SEND_EMAIL :
					sendRSSEmail(event as GetRSSEvent);
				break;	
			}
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
		
		/**
		 * Get the layout
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
			if(_model.debug){ Logger.info('Layout Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}
		
		
		/**
		 * Send RSS item as an email to a friend
		 */
		private function sendRSSEmail(event:GetRSSEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_sendRSSEmail, onFault_sendRSSEmail);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;

			// tells that is submitting the form
			_model.isSubmitting = true;

			delegate.send_user_email( event.params );
		}

		private function onResults_sendRSSEmail(data:Object):void 
		{
			if(_model.debug) Logger.info('Sending Success', data.result, ObjectUtil.toString(data.result));

			_model.dataLoading = false;
			
			if (data.result.state === true)
				_model.errorVO = new ErrorVO( 'The email was successfully sent', 'successBox', true );
			else
				_model.errorVO = new ErrorVO( 'There was an error trying to send the email', 'errorBox', true );
			
			_model.onClose = function():void { _model.isSubmitting = false; }
		}	

		private function onFault_sendRSSEmail(data:Object):void
		{
			if(_model.debug) Logger.info('Sending Fault', ObjectUtil.toString(data.fault));	

			_model.errorVO = new ErrorVO( 'There was an error processing the emails!' + data.fault, 'errorBox', true );

			_model.onClose = function():void { _model.isSubmitting = false;	}
			
			_model.dataLoading = false;			
		}
		
		
		/**
		 * Get the table layouts to build forms
		 */			
		private function getStruktorLayout(event:GetStruktorLayoutEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getStruktorLayout, onFault_getStruktorLayout);
			var delegate:LayoutDelegate = new LayoutDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getLayouts();			
		}
				
		private function onResult_getStruktorLayout(event:Object):void 
		{
			//if(_model.debug) Logger.info('getStruktorLayout Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;
			
			// loop through the tables and add them to the struktorLayout view class
			for each ( var table:Object in event.result )
				if(_model.struktorLayout.hasOwnProperty(table.table))
					_model.struktorLayout[table.table] = table;
			
			// tell the model that the layouts are in place	
			_model.struktorLayout.loaded = true;	
		}
		
		public function onFault_getStruktorLayout(event:Object):void
		{
			if(_model.debug) Logger.info('getStruktorLayout Fail', ObjectUtil.toString(event));		
			
			_model.dataLoading = false;
		}

	}
}