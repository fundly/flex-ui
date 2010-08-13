package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.PluginsDelegate;
	import com.enilsson.elephanttrakker.business.RecordsDelegate;
	import com.enilsson.elephanttrakker.events.modules.email.EmailEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class EmailCommand extends SequenceCommand  implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function EmailCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('Email Command', ObjectUtil.toString(event.type));

			switch(event.type)
			{
				case EmailEvent.EMAIL_CONTACTS :
					fetchContacts(event as EmailEvent);
				break;
				case EmailEvent.EMAIL_ATTACHMENTS :
					fetchAttachments(event as EmailEvent);
				break;
				case EmailEvent.EMAIL_TEMPLATES :
					fetchTemplates(event as EmailEvent);
				break;
				case EmailEvent.EMAIL_SEND_EMAILS :
					sendEmails(event as EmailEvent);
				break;
			}			
		}
		
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
		

		/**
		 * Get the contacts records
		 */
		private function fetchContacts(event:EmailEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_fetchContacts, onFault_fetchContacts);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.get_all_contacts();
		}

		private function onResults_fetchContacts(data:Object):void 
		{
			if(_model.debug) Logger.info('Email Success', ObjectUtil.toString(data.result), ObjectUtil.toString(_model.email.selectedEmails));
			
			// add some convenience items to the contacts array collection
			var arrCol:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result.contacts)
			{
				item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;
				item['fullName'] = item.lname + ', ' + item.fname;
				

				if (_model.email.selectedEmails.indexOf(item['id']) != -1)
					item['selected'] = true;
				else
					item['selected'] = false;
				
				arrCol.addItem(item);				
			}
			
			// assign the altered array collection to the model for binding
			_model.email.contacts = arrCol;
			_model.email.selectedEmails = new Array();
			_model.dataLoading = false;
		}	

		private function onFault_fetchContacts(data:Object):void
		{
			if(_model.debug) Logger.info('Email Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}
		
		
		/**
		 * Get the resources records
		 */
		private function fetchAttachments(event:EmailEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_fetchAttachments, onFault_fetchAttachments);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			
			Logger.info('Get Email Attachments');
			// Filter out unpublished attachments
				var whereObj:Object =  new Object();
					whereObj['statement'] = '(1)';
					whereObj[1] = { 
						'what' : 'email_attachments.publish',
						'val' : 1,
						'op' : '='
					};

			var recordsVO:RecordsVO = new RecordsVO( 
										'email_attachments', 
										whereObj, 
										'email_attachments.id ASC', 
										0, 
										1000
										)

			delegate.getRecords( recordsVO );
		}

		private function onResults_fetchAttachments(data:Object):void 
		{
			if(_model.debug) Logger.info('Attachments Success', ObjectUtil.toString(data.result));

			var arrCol:ArrayCollection = new ArrayCollection()
			arrCol.addItem({ label: 'Select an attachment', data: ''});

			for each( var item:Object in data.result.email_attachments)
				arrCol.addItem({label:item.title + " ("+Math.ceil(item.filesize/1024)+" KB)", data:item.attachment_id});

			_model.email.email_attachments = arrCol;
			
			_model.dataLoading = false;
		}	

		private function onFault_fetchAttachments(data:Object):void
		{
			if(_model.debug) Logger.info('Email Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}
		
	
		/**
		 * Get the templates records
		 */
		private function fetchTemplates(event:EmailEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_fetchTemplates, onFault_fetchTemplates);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getRecords( new RecordsVO( 'email_user_templates', null, null, 0, 500 ) );
		}

		private function onResults_fetchTemplates(data:Object):void 
		{
			if(_model.debug) Logger.info('Templates Success', ObjectUtil.toString(data.result));

			var arrCol:ArrayCollection = new ArrayCollection()
			arrCol.addItem({label:'Select a template', data:''});
			
			for each( var item:Object in data.result.email_user_templates)
			{
				// replace variables in the template with appropriate values
				// Any change here should be reflected in the admin - Email_User.mxml's sendTestEmail function
				var templateText:String = item.description;
				var subjectText:String = item.subject;

				var df:DateFormatter = new DateFormatter();
				df.formatString = 'MM/DD/YYYY';

				templateText = templateText.replace(/{full_name}/g, _model.session.fullname);
				templateText = templateText.replace(/{fname}/g, _model.session.fname);
				templateText = templateText.replace(/{lname}/g, _model.session.lname);
				templateText = templateText.replace(/{email}/g, _model.session.email);
				templateText = templateText.replace(/{fid}/g, _model.session.data._fid);
				templateText = templateText.replace(/{pledge_total}/g, "$"+_model.session.data._pledge_total);
				templateText = templateText.replace(/{contrib_total}/g, "$"+_model.session.data._contrib_total);
				templateText = templateText.replace(/{phone}/g, _model.session.data._phone);
				templateText = templateText.replace(/{fundraising_goal}/g, "$"+_model.session.data._fundraising_goal);
				templateText = templateText.replace(/{zip}/g, _model.session.data._zip);
				templateText = templateText.replace(/{address1}/g, _model.session.data._address1);
				templateText = templateText.replace(/{address2}/g, _model.session.data._address2);
				templateText = templateText.replace(/{city}/g, _model.session.data._city);
				templateText = templateText.replace(/{state}/g, _model.session.data._state);
				templateText = templateText.replace(/{date}/g, df.format(new Date() ));

				subjectText = subjectText.replace(/{full_name}/g, _model.session.fullname);
				subjectText = subjectText.replace(/{fname}/g, _model.session.fname);
				subjectText = subjectText.replace(/{lname}/g, _model.session.lname);
				subjectText = subjectText.replace(/{email}/g, _model.session.email);
				subjectText = subjectText.replace(/{fid}/g, _model.session.data._fid);
				subjectText = subjectText.replace(/{pledge_total}/g, "$"+_model.session.data._pledge_total);
				subjectText = subjectText.replace(/{contrib_total}/g, "$"+_model.session.data._contrib_total);
				subjectText = subjectText.replace(/{phone}/g, _model.session.data._phone);
				subjectText = subjectText.replace(/{fundraising_goal}/g, "$"+_model.session.data._fundraising_goal);
				subjectText = subjectText.replace(/{zip}/g, _model.session.data._zip);
				subjectText = subjectText.replace(/{address1}/g, _model.session.data._address1);
				subjectText = subjectText.replace(/{address2}/g, _model.session.data._address2);
				subjectText = subjectText.replace(/{city}/g, _model.session.data._city);
				subjectText = subjectText.replace(/{state}/g, _model.session.data._state);
				subjectText = subjectText.replace(/{date}/g, df.format(new Date() ));

				arrCol.addItem({label:item.title, data:templateText, subject:subjectText});
			}

			_model.email.templates = arrCol;
			
			_model.dataLoading = false;
		}	

		private function onFault_fetchTemplates(data:Object):void
		{
			if(_model.debug) Logger.info('Email Fault', ObjectUtil.toString(data.fault));
			
			_model.dataLoading = false;			
		}
		


		/**
		 * Send emails
		 */
		private function sendEmails(event:EmailEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_sendEmails, onFault_sendEmails);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;

			_model.email.isSubmitting = true;
			_model.email.sendingEmails = true;

			var emailList:Object = new Object();

			if(_model.email.bccEmail)
				emailList['bcc'] = _model.email.emails
			else
				emailList['to'] = _model.email.emails

			var params:Object = { 
				'emails' : emailList,
				'subject' : _model.email.subject, 
				'message' : _model.email.message, 
				'template_id' : _model.email.templateID == 0 ? "" : _model.email.templateID,
				'attachments' : _model.email.attachment 
			}
			

			Logger.info('Sending Email', ObjectUtil.toString(params));


			delegate.send_user_email( params );
		}

		private function onResults_sendEmails(event:Object):void 
		{
			if(_model.debug) Logger.info('Sending Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			
			if (event.result.state === true) 
			{
				_model.email.errorVO = new ErrorVO( 'The emails were successfully sent', 'successBox', true );
			
				this.nextEvent = new EmailEvent(EmailEvent.EMAIL_SENT);
				this.executeNextCommand();
				this.nextEvent = null;
			} 
			else
			{
				var eMsg:String = 'There was an error trying to send the emails:<br><br>';
				if(typeof(event.result.errors) == 'string')
					eMsg += event.result.errors;
				else
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
				
				_model.email.errorVO = new ErrorVO( eMsg, 'errorBox', true );
			}
			
			_model.email.isSubmitting = false;		
			_model.email.onClose = function():void { _model.email.sendingEmails = false; }
		}	

		private function onFault_sendEmails(data:Object):void
		{
			if(_model.debug) Logger.info('Sending Fault', ObjectUtil.toString(data.fault));	

			_model.email.errorVO = new ErrorVO( 'There was an error processing the emails!' + data.fault, 'errorBox', true );
			_model.email.isSubmitting = false;
			_model.email.onClose = function():void { _model.email.sendingEmails = false; }
			
			_model.dataLoading = false;			
		}
		
	}
}