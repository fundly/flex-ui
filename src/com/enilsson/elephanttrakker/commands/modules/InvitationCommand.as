package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.InvitationDelegate;
	import com.enilsson.elephanttrakker.business.RecordsDelegate;
	import com.enilsson.elephanttrakker.events.modules.invitation.InvitationEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.EmailVO;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	import com.enilsson.utils.EDateUtil;
	import com.enilsson.utils.struktorForm.ConvertRTEText;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class InvitationCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function InvitationCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('Invitation Command', ObjectUtil.toString(event.type));

			switch(event.type)
			{
				case InvitationEvent.INVITATION_SEND:
					sendInvitation(event as InvitationEvent);
				break;
				case InvitationEvent.INVITATION_GET_LOG:
					getLog(event as InvitationEvent);
			}
		}
		
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
		
		/**
		 * Send invitation email to new fundraiser
		 */
		private function sendInvitation(event:InvitationEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_sendInvitation, onFault_sendInvitation);
			var delegate:InvitationDelegate = new InvitationDelegate(handlers);
			
			_model.dataLoading = true;

			// tells that is submitting the form
			_model.invitation.isSubmitting = true;

			// show the message that is sending the emails
			_model.invitation.sendingInvitation = true;

			var df:DateFormatter = new DateFormatter();
			df.formatString = 'MM/DD/YYYY';

			_model.invitation.template_variables = {
				'fname':_model.invitation.fname,
				'lname':_model.invitation.lname,
				'recruiter_fname':_model.session.fname,
				'recruiter_lname':_model.session.lname,
				'email':_model.invitation.email,
				'organization':_model.orgName, 
				'personal_message':_model.invitation.message,
				'subject':_model.invitation.subject,
				'url':_model.baseURL,
				'date':df.format(new Date())
			};

			if(_model.debug) Logger.info('sendInvitation Vars', ObjectUtil.toString(_model.invitation.template_variables));

			delegate.sendInvitation();
		}
		private function onResults_sendInvitation(data:Object):void 
		{
			if(_model.debug) Logger.info('sendInvitation Success', ObjectUtil.toString(data.result));

			_model.dataLoading = false;
			
			// remove the message that is sending the emails
			_model.invitation.sendingInvitation = false;
			
			if (data.result.state === true) {
				_model.invitation.errorVO = new ErrorVO( 'The invitation was successfully sent', 'successBox', true );
				this.nextEvent = new InvitationEvent(InvitationEvent.INVITATION_SENT);
				this.executeNextCommand();
				this.nextEvent = null;
			}
			else 
			{
				_model.invitation.errorVO = new ErrorVO( 'There was an error trying to send the invitation<br><br>- ' + data.result.error[0], 'errorBox', true );
			}
			
			_model.invitation.onClose = function():void {
				_model.invitation.isSubmitting = false;
			}
			
			
		}	
		private function onFault_sendInvitation(data:Object):void
		{
			if(_model.debug) Logger.info('sendInvitation Fault', ObjectUtil.toString(data.fault));	

			// remove the message that is sending the emails
			_model.invitation.sendingInvitation = false;

			_model.invitation.errorVO = new ErrorVO( 'There was an error processing this invitation!<br><br>- ' + data.fault, 'errorBox', true );

			_model.invitation.onClose = function():void {
				_model.invitation.isSubmitting = false;
			}
			
			_model.dataLoading = false;
		}


		/**
		 * Send invitation email to new fundraiser
		 */
		private function getLog(event:InvitationEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getLog, onFault_getLog);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;

			var whereObj:Object = new Object();
			whereObj['statement'] = '(1) AND (2)';
			// select email only from this user
			whereObj[1] = { 
				'what' : 'email_log.user_id',
				'val' : _model.session.user_id,
				'op' : '='
			};
			// select only invitation emails
 			whereObj[2] = { 
				'what' : 'email_log.template_id',
				'val' : _model.serverVariables.invitation_template_id,
				'op' : '='
			};

			var recordsVO:RecordsVO = new RecordsVO( 
				'email_log(user_id<fname:lname:_fid>)', 
				whereObj, 
				'email_log.created_on DESC'
				) 

			if(_model.debug) Logger.info('getLog Vars', ObjectUtil.toString(recordsVO));

			delegate.getRecords(recordsVO);
		}
		
		private function onResults_getLog(data:ResultEvent):void 
		{
			if(_model.debug) Logger.info('getLog Success', ObjectUtil.toString(data.result));

			_model.dataLoading = false;

			_model.invitation.sentList = new ArrayCollection();

			for each(var item:Object in data.result.email_log)
			{			
				var emailVO:EmailVO = new EmailVO(item.to,item.subject,ConvertRTEText.fromXHtml(item.content));
				emailVO.date = EDateUtil.timestampToLocalDate(item.created_on);
				emailVO.fname = item.user_id.fname;
				emailVO.lname = item.user_id.lname;

				_model.invitation.sentList.addItem(emailVO);
			}
			
			_model.invitation.selectedLogIndex = 0;
		}
		
		private function onFault_getLog(data:FaultEvent):void
		{
			if(_model.debug) Logger.info('getLog Fault', ObjectUtil.toString(data.fault));	

			_model.invitation.errorVO = new ErrorVO( 'There was an error retrieving list of sent invitations!<br><br>- ' + data.fault, 'errorBox', true );

			_model.dataLoading = false;
		}
	}
}