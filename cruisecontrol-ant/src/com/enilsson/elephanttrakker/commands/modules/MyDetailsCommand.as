package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.MyContactsDelegate;
	import com.enilsson.elephanttrakker.business.MyDetailsDelegate;
	import com.enilsson.elephanttrakker.events.modules.my_details.*;
	import com.enilsson.elephanttrakker.events.session.UpdateSessionEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class MyDetailsCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MyDetailsCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('MyDetails Command', ObjectUtil.toString(event.type));		
			
			switch(event.type)
			{
				case MyDetailsEvent.MYDETAILS_UPSERT :
					upsertDetails(event as MyDetailsEvent);
				break;
				case MyDetailsEvent.MYDETAILS_CHANGE_EMAIL :
					changeEmail(event as MyDetailsEvent);
				break;
				case MyDetailsEvent.MYDETAILS_CHANGE_PWD :
					changePWD(event as MyDetailsEvent);
				break;
				case MyDetailsEvent.MYDETAILS_PASSWORD_CHANGED :
					PWDChanged();
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
		private function upsertDetails(event:MyDetailsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertDetails, onFault_upsertDetails);
			var delegate:MyDetailsDelegate = new MyDetailsDelegate(handlers);
			
			_model.my_details.formProcessing = true;
			_model.my_details.isSubmitting = true;
			
			delegate.upsertDetails( event.params );
		}
		
		private function onResults_upsertDetails(data:Object):void 
		{
			if(_model.debug) Logger.info('upsertDetails Success', ObjectUtil.toString(data.result));
			
			switch(data.result.state)
			{
				case '99' :
					_model.my_details.errorVO = new ErrorVO('Your details were successfully edited', 'successBox', true );
					
					// update the session once the details have been updated
					this.nextEvent = new UpdateSessionEvent();
					this.executeNextCommand();
				break;
				
				case '-99' :				
					var eMsg:String = '';
					for(var i:String in data.result.errors)
						eMsg += '- ' + data.result.errors[i] + '<br>'
					
					_model.my_details.errorVO = new ErrorVO( 
						'There was a problem processing your details:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
			
			_model.my_details.isSubmitting = false;
			_model.my_details.formProcessing = false;
		}	
		
		private function onFault_upsertDetails(data:Object):void
		{
			if(_model.debug) Logger.info('upsertDetails Fault');	

			_model.my_details.formProcessing = false;			
			_model.my_details.isSubmitting = false;
		}	


		/**
		 * Change Password
		 */
		private function changePWD(event:MyDetailsEvent):void
		{			
			if(_model.debug) Logger.info('changing Password');

			var handlers:IResponder = new mx.rpc.Responder(onResults_changePWD, onFault_changePWD);
			var delegate:MyDetailsDelegate = new MyDetailsDelegate(handlers);
			
			_model.my_details.formProcessing = true;
			
			delegate.changePWD( event.params.new_password, event.params.old_password );
		}
		
		private function onResults_changePWD(data:Object):void 
		{
			if(_model.debug) Logger.info('changePWD Success', ObjectUtil.toString(data.result),_model.my_details.newPWD,_model.my_details.oldPWD);

			switch(data.result.state)
			{
				case true :
							
					this.nextEvent = new MyDetailsEvent(MyDetailsEvent.MYDETAILS_PASSWORD_CHANGED);
					this.executeNextCommand();
					this.nextEvent = null;			

					_model.my_details.errorVO = new ErrorVO( 
						'Your password has been changed successfully!', 
						'successBox', 
						true 
					);
					
				break;
				
				default :
				case false :
			
					_model.my_details.errorVO = new ErrorVO( 
						'There was a problem processing your details:<br><br>' + data.result.error, 
						'errorBox', 
						true 
					);
					
				break;	
			}
						
			_model.my_details.formProcessing = false;
		}	
		
		private function onFault_changePWD(data:Object):void
		{
			if(_model.debug) Logger.info('changePWD Fault', ObjectUtil.toString(data.fault));	

			_model.my_details.newPWD = '';
			_model.my_details.oldPWD = '';

			_model.my_details.errorVO = new ErrorVO( 
				'There was a problem processing your details!', 
				'errorBox', 
				true 
			);

			_model.my_details.formProcessing = false;			
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
		 * Upsert a contact record
		 */
		private function upsertContact(event:MyDetailsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertContact, onFault_upsertContact);
			var delegate:MyContactsDelegate = new MyContactsDelegate(handlers);
			
			delegate.upsertContact( event.params );
		}
		
		private function onResults_upsertContact(data:Object):void 
		{
			if(_model.debug) Logger.info('upsert Contact Success', ObjectUtil.toString(data.result));
			
			switch(data.result.state)
			{
				case '98' :
				case '99' :
					_model.my_contacts.contacts = new ArrayCollection();
					
					this.nextEvent = new UpdateSessionEvent();
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
					
					_model.my_details.errorVO = new ErrorVO( 
						'There was a problem processing your contact details:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}	
		private function onFault_upsertContact(data:Object):void
		{
			if(_model.debug) Logger.info('upsert Contact Fault');
		}	

		
		/**
		 * Change email for the users account
		 */
		private function changeEmail(event:MyDetailsEvent):void
		{			
			if(_model.debug) Logger.info('changing email');

			var handlers:IResponder = new mx.rpc.Responder(onResults_changeEmail, onFault_changeEmail);
			var delegate:MyDetailsDelegate = new MyDetailsDelegate(handlers);
			
			_model.my_details.formProcessing = true;
			
			delegate.changeEmail( event.params.email, event.params.password );
		}
		
		private function onResults_changeEmail(data:Object):void 
		{
			if(_model.debug) Logger.info('changeEmail Success', data.result.state, ObjectUtil.toString(data.result));

			switch(data.result.state)
			{
				case true :
					this.nextEvent = new UpdateSessionEvent();
					this.executeNextCommand();
					this.nextEvent = null;	
					
					_model.my_details.errorVO = new ErrorVO( 
						'Your email has been changed successfully!', 
						'successBox', 
						true 
					);													
				break;
				case false :			
					_model.my_details.errorVO = new ErrorVO( 
						'There was a problem updating your email:<br><br>' + data.result.error, 
						'errorBox', 
						true 
					);
				break;	
			}
		
			_model.my_details.formProcessing = false;
		}	
		
		private function onFault_changeEmail(data:Object):void
		{
			if(_model.debug) Logger.info('changeEmail Fault');	

			_model.my_details.formProcessing = false;			
		}	
				
	}
}