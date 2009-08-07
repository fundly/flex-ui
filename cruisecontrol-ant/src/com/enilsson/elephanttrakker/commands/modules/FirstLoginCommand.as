package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.MyDetailsDelegate;
	import com.enilsson.elephanttrakker.business.PluginsDelegate;
	import com.enilsson.elephanttrakker.business.RecordDelegate;
	import com.enilsson.elephanttrakker.events.modules.first_login.FirstLoginEvent;
	import com.enilsson.elephanttrakker.events.modules.my_details.*;
	import com.enilsson.elephanttrakker.events.session.UpdateSessionEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	import com.enilsson.elephanttrakker.vo.RecordVO;
	
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class FirstLoginCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function FirstLoginCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('FirstLogin Command', ObjectUtil.toString(event.type));		

			switch(event.type)
			{
				case FirstLoginEvent.FIRSTLOGIN_UPSERTCONTACT :
					upsertContact(event as FirstLoginEvent);
				break;
				case FirstLoginEvent.FIRSTLOGIN_UPSERTDETAILS :
					upsertDetails(event as FirstLoginEvent);
				break;				
				case FirstLoginEvent.FIRSTLOGIN_CHANGEPWD :
					changePWD(event as FirstLoginEvent);
				break;
				case FirstLoginEvent.FIRSTLOGIN_PASSWORD_CHANGED :
					PWDChanged();
				break;
				case FirstLoginEvent.FIRSTLOGIN_LOGGEDIN :
					registerLogin( event as FirstLoginEvent );
				break;
			}				
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }



		/**
		 * Upsert a contact record
		 */
		private function upsertContact(event:FirstLoginEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertContact, onFault_upsertContact);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.firstlogin.formProcessing = true;
			
			delegate.upsertContact( event.params );
		}
		
		private function onResults_upsertContact(data:Object):void 
		{
			if(_model.debug) Logger.info('Upsert First Contact Success', ObjectUtil.toString(data.result));
			
			switch(data.result.state)
			{
				case '98' :
				case '99' :
					_model.firstlogin.contact_id = data.result.details;
					_model.firstlogin.formVariables['_contact_id'] = _model.firstlogin.contact_id;
					
					this.nextEvent = new FirstLoginEvent( FirstLoginEvent.FIRSTLOGIN_UPSERTDETAILS, _model.firstlogin.formVariables);
					this.executeNextCommand();
					this.nextEvent = null;										
					
				break;
				case '-99' :				
					var eMsg:String = '';
					if (data.result.errors is Array) 
					{
						for(var i:String in data.result.errors)
							eMsg += '- ' + data.result.errors[i] + '<br>'
					}
					else
						eMsg = data.result.errors;
					
					_model.firstlogin.errorVO = new ErrorVO( 
						'There was a problem processing your details:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}	
		
		private function onFault_upsertContact(data:Object):void
		{
			if(_model.debug) Logger.info('upsert First Contact Fault', ObjectUtil.toString(data.fault));

			_model.firstlogin.errorVO = new ErrorVO( 'There was an error processing your details!' + data.fault, 'errorBox', true );						
			_model.firstlogin.formProcessing = false;			
		}	


		/**
		 * Update login details
		 */
		private function upsertDetails( event:FirstLoginEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertDetails, onFault_upsertDetails);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			delegate.upsertRecord( new RecordVO( 'tr_users', 0, null, event.params ) );
		}
		
		private function onResults_upsertDetails(data:Object):void 
		{
			if(_model.debug) Logger.info('upsertFirstLoginDetails Success', ObjectUtil.toString(data.result));
			
			switch(data.result.state)
			{
				case '99' :
					this.nextEvent = new FirstLoginEvent(
						FirstLoginEvent.FIRSTLOGIN_CHANGEPWD,
						{ 'new_password' : _model.firstlogin.newPWD, 'old_password' : _model.firstlogin.oldPWD }
					);
					this.executeNextCommand();
					this.nextEvent = null;
				break;
				
				default :
				case '-99' :				
					var eMsg:String = '';
					if (data.result.errors is Array) 
					{
						for(var i:String in data.result.errors)
							eMsg += '- ' + data.result.errors[i] + '<br>'
					} 
					else
						eMsg = '- ' + data.result.errors;
						
					_model.firstlogin.errorVO = new ErrorVO( 
						'There was a problem processing your details:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}	
		
		private function onFault_upsertDetails(data:Object):void
		{
			if(_model.debug) Logger.info('upsertDetails Fault', ObjectUtil.toString(data.fault));

			_model.firstlogin.errorVO = new ErrorVO( 'There was an error processing your details!<br><br>- ' + data.fault, 'errorBox', true );						
			_model.firstlogin.formProcessing = false;			
		}	


		/**
		 * Change Password
		 */
		private function changePWD( event:FirstLoginEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_changePWD, onFault_changePWD);
			var delegate:MyDetailsDelegate = new MyDetailsDelegate(handlers);
			
			delegate.changePWD( event.params.new_password, event.params.old_password );
		}
		
		private function onResults_changePWD(data:Object):void 
		{
			if(_model.debug) Logger.info('changePWD Success', ObjectUtil.toString(data.result));

			switch(data.result.state)
			{
				case true :
				
					this.nextEvent = new FirstLoginEvent( FirstLoginEvent.FIRSTLOGIN_PASSWORD_CHANGED );
					this.executeNextCommand();
					this.nextEvent = null;			

					_model.firstlogin.loginBoxState = 1;
					_model.firstlogin.contact_id = 0;
					
				break;
				
				default :
				case false :
				
					_model.firstlogin.errorVO = new ErrorVO( 
						'There was a problem processing your details:<br><br>- ' + data.result.error, 
						'errorBox', 
						true 
					);
					
				break;	
			}
						
			_model.firstlogin.formProcessing = false;
		}	
		
		private function onFault_changePWD(data:Object):void
		{
			if(_model.debug) Logger.info('First Login changePWD Fault', ObjectUtil.toString(data.fault));	

			_model.firstlogin.newPWD = '';
			_model.firstlogin.oldPWD = '';

			_model.firstlogin.errorVO = new ErrorVO( 
				'There was a problem processing your details!<br><br>- ' + data.fault, 
				'errorBox', 
				true 
			);

			_model.firstlogin.formProcessing = false;			
		}	
		

		/**
		 * Change Password
		 */
		private function PWDChanged():void
		{			
			if(_model.debug) Logger.info('Password Changed');
			
			this.nextEvent = new UpdateSessionEvent();
			this.executeNextCommand();
			this.nextEvent = null;	
		}
		
		
		/**
		 * Register the login for the first time
		 */
		private function registerLogin ( event:FirstLoginEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_registerLogin, onFault_registerLogin);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			if(_model.debug) Logger.info('Register Login', event.params);
			
			delegate.upsertRecord( new RecordVO( 'tr_users', 0, null, event.params ) );
		}

		private function onResults_registerLogin ( event:Object ):void
		{
			switch ( event.result.state )
			{
				case '98' :
				case '99' :
					if(_model.debug) Logger.info('Login registered');
				break;
				case '-99' :
					var eMsg:String = '';
					if ( event.result.errors is Array ) 
					{
						for(var i:String in event.result.errors)
							eMsg += '- ' + event.result.errors[i] + '<br>'
					} 
					else
						eMsg = '- ' + event.result.errors;
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing your details:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;
			}
		}
		
		private function onFault_registerLogin ( event:Object ):void
		{
			if(_model.debug) Logger.info('Login registering failed', ObjectUtil.toString(event) );
			
			_model.errorVO = new ErrorVO( 
				'There was a problem processing your details!<br><br>- ' + event.fault, 
				'errorBox', 
				true 
			);
		}
				
	}
		
}