package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.MessageCenterDelegate;
	import com.enilsson.elephanttrakker.events.modules.message_center.MessageCenterEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class MessageCenterCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MessageCenterCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('Message Center Command', ObjectUtil.toString(event.type));

			switch(event.type)
			{
				case MessageCenterEvent.MESSAGES_ACTION :
					var e:MessageCenterEvent = (event as MessageCenterEvent);

					switch (e.obj.action)
					{
						case 'accept':
							acceptRequest(e);
						break;
						case 'reject':
							rejectRequest(e);
						break;
						case 'delete':
							deleteMessage(e);
						break;
					}
				break;
				case MessageCenterEvent.MESSAGES_GET :
					fetchMessages(event as MessageCenterEvent);
				break;
				case MessageCenterEvent.MESSAGES_GET_SENT :
					getSent(event as MessageCenterEvent);
				break;				
				case MessageCenterEvent.MESSAGES_GET_UNREAD :
					getUnreadMessages(event as MessageCenterEvent);
				break;
				case MessageCenterEvent.MESSAGES_STATUS:
					setRead(event as MessageCenterEvent);
				break;
				case MessageCenterEvent.SEARCH:
					searchFundRaisers(event as MessageCenterEvent);
				break;
				case MessageCenterEvent.MESSAGES_SEND:
					sendMessage(event as MessageCenterEvent);
				break;
				case MessageCenterEvent.MESSAGES_SENT:
					messageSent();
				break;
				case MessageCenterEvent.MESSAGES_GET_LABEL :
					searchLabel(event as MessageCenterEvent);
				break;
			}
		}
		
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
		

		/**
		 * Get the messages records
		 */
		private function fetchMessages(event:MessageCenterEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_fetchMessages, onFault_fetchMessages);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getMessages();
		}
		
		private function onResults_fetchMessages(data:Object):void 
		{
			if(_model.debug) Logger.info('Fetch Messages Success', ObjectUtil.toString(data.result));
			
			// add some convenience items to the contacts array collection
			var messages:ArrayCollection = new ArrayCollection()

			for each( var item:Object in data.result.msgs)
			{
				switch(item.action) 
				{
					case 'downline':
						item['description'] = _model.options.downline_request.replace(new RegExp(/{from_name}/gi), item.from_name);
						item['msgType'] = 'Downline request';
						messages.addItem(item);
					break;				
					case 'contacts':
						item['description'] = _model.options.contacts_request.replace(new RegExp(/{from_name}/gi), item.from_name);
						item['msgType'] = 'Contacts request';
						messages.addItem(item);				
					break;
					case 'message' :
					case 'msg' :
						item['description'] = item.msg;
						item['msgType'] = 'Message';
						messages.addItem(item);				
					break;
				}
			}

			// add the message data to the model
			_model.message_center.messages = messages
			
			// register the number of unread messages
			setSiteMsgs();

			_model.dataLoading = false;
		}	
		
		private function onFault_fetchMessages(data:Object):void
		{
			if(_model.debug) Logger.info('Fetch Messages Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}


		/**
		 * Get the messages records
		 */
		private function getSent(event:MessageCenterEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getSent, onFault_getSent);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getSent();
		}
		
		private function onResults_getSent(data:Object):void 
		{
			if(_model.debug) Logger.info('getSent Success', ObjectUtil.toString(data.result));
			
			// add some convenience items to the contacts array collection
			var messages:ArrayCollection = new ArrayCollection()

			for each( var item:Object in data.result.msgs)
			{
				switch(item.action) 
				{
					case 'downline':
						item['description'] = item.from_name + ' has requested you be a member of their downline. This means they will see your pledge and contributions totals, and your downline will roll up into theirs aswell.';
						item['msgType'] = 'Downline request';
						messages.addItem(item);
					break;				
					case 'contacts':
						item['description'] = item.from_name + ' has requested that you make your contacts available. They will not see any pledges you have recorded against your contacts, but they will be able to record pledges of their own against your list.';
						item['msgType'] = 'Contacts request';
						messages.addItem(item);				
					break;
					case 'message' :
					case 'msg' :
						item['description'] = item.msg;
						item['msgType'] = 'Message';
						messages.addItem(item);				
					break;
				}
			}

			// add the message data to the model
			_model.message_center.sentMessages = messages

			_model.dataLoading = false;
		}	
		
		private function onFault_getSent(data:Object):void
		{
			if(_model.debug) Logger.info('getSent Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}		
		
		
		
		/**
		 * Get the unread message so they can display the number to the user
		 */
		private function getUnreadMessages(event:MessageCenterEvent):void
		{
			if(_model.debug) Logger.info('Requesting Unread Messages', ObjectUtil.toString(event.obj));
			var handlers:IResponder = new mx.rpc.Responder(onResults_getUnreadMessages, onFault_getUnreadMessages);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			_model.dataLoading = true;
				
			delegate.getUnread();
		}
		
		private function onResults_getUnreadMessages(data:Object):void 
		{
			if(_model.debug) Logger.info('Get Unread Messages Success', ObjectUtil.toString(data.result));
				
			var toRead:uint = 0;
			for each( var item:Object in data.result.msgs)
				toRead++;
	
			_model.siteMsgs = toRead;
			
			if (toRead > 0)
			{
				// refresh the sent messages
				this.nextEvent = new MessageCenterEvent(MessageCenterEvent.MESSAGES_GET);
				this.executeNextCommand();
				this.nextEvent = null;
			}
			
			_model.dataLoading = false;
		}	
		
		private function onFault_getUnreadMessages(event:FaultEvent):void
		{
			event.preventDefault();
			event.stopImmediatePropagation();
			
			if(_model.debug) Logger.info('Get Unread Messages Fault', ObjectUtil.toString(event.fault));	
			
			_model.dataLoading = false;			
		}
			
			
		/**
		 * set accept request 
		 */
		private function acceptRequest(event:MessageCenterEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_acceptRequest, onFault_acceptRequest);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			_model.dataLoading = true;
           	_model.message_center.index = _model.message_center.messages.getItemIndex(event.obj.data);

			delegate.acceptRequest(event.obj.tablename, event.obj.data);
		}
		
		private function onResults_acceptRequest(data:Object):void 
		{
			if(_model.debug) Logger.info('accept request Success', ObjectUtil.toString(data.result));
			
			// delete the message once it has been accepted
			this.nextEvent = new MessageCenterEvent(
            	MessageCenterEvent.MESSAGES_ACTION, {
            		'id' : _model.message_center.requestResponse.id, 
            		'action' : 'delete',
            		'index': _model.message_center.index,
            		'data' : _model.message_center.requestResponse,
            		'array':'messages'
            	}
            )
			this.executeNextCommand();
			this.nextEvent = null;
		}	
		
		private function onFault_acceptRequest(data:Object):void
		{
			if(_model.debug) Logger.info('accept request Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}

		
		/**
		 * set reject request 
		 */
		private function rejectRequest(event:MessageCenterEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_rejectRequest, onFault_rejectRequest);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			_model.dataLoading = true;

           _model.message_center.index = _model.message_center.messages.getItemIndex(event.obj.data);
	
			delegate.deleteMessage(event.obj.id);
		}
		private function onResults_rejectRequest(data:Object):void 
		{
			if(_model.debug) Logger.info('reject request Success', ObjectUtil.toString(data.result));
			
			_model.dataLoading = false;
			_model.message_center.messages.removeItemAt(_model.message_center.index);
			setSiteMsgs();
			
			// refresh the sent messages
			this.nextEvent = new MessageCenterEvent( MessageCenterEvent.MESSAGES_GET_SENT );
			this.executeNextCommand();
			this.nextEvent = null;
		}	
		private function onFault_rejectRequest(data:Object):void
		{
			if(_model.debug) Logger.info('reject request Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}



		/**
		 * set status 
		 */
		private function setRead(event:MessageCenterEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_setStatus, onFault_setStatus);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			_model.dataLoading = true;
			
			if(_model.debug){ Logger.info('set status', event.obj.id,event.obj.viewed); }
				
			delegate.setMessageStatus(event.obj.id,event.obj.viewed);
		}
		private function onResults_setStatus(data:Object):void 
		{
			if(_model.debug){ Logger.info('set status Success', ObjectUtil.toString(data.result)); }
			
			_model.dataLoading = false;
			
			setSiteMsgs();			
		}	
		private function onFault_setStatus(data:Object):void
		{
			if(_model.debug){ Logger.info('set status Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			
		}		


		/**
		 * set delete request 
		 */
		private function deleteMessage(event:MessageCenterEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteMessage, onFault_deleteMessage);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			_model.dataLoading = true;

           _model.message_center.index = event.obj.index;
           _model.message_center.array = event.obj.array;
	
			delegate.deleteMessage(event.obj.id);
		}
		private function onResults_deleteMessage(data:Object):void 
		{
			if(_model.debug) Logger.info('deleteMessage Success', ObjectUtil.toString(data.result));
			
			_model.dataLoading = false;

			switch(data.result.state)
			{
				case '-88' :
					var eMsg:String = '';
					for(var i:String in data.result.errors)
					{
						eMsg += '- ' + data.result.errors[i] + '<br>'
					}
					_model.message_center.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
					_model.message_center.onClose = function():void {
						_model.message_center.isSubmitting = false;
					}
				break;
				default:	
					_model.message_center[_model.message_center.array].removeItemAt(_model.message_center.index);
					setSiteMsgs();
					
					// if deleting a request, send a site msg informing the requesting fundraiser of the decision
					if(_model.message_center.requestResponse != null)
					{
						switch(_model.message_center.requestResponse.requestAction)
						{
							case 'accept' :
								// send a message back to the fundraiser saying that the request has been accepted
								this.nextEvent = new MessageCenterEvent(
								 	MessageCenterEvent.MESSAGES_SEND, { 
								 		'action' : 'msg',
								 		'text' : _model.message_center.requestResponse.to_name + ' has accepted your ' + _model.message_center.requestResponse.msgType,
								 		'to_id' : _model.message_center.requestResponse.from_id,
								 		'subject' : _model.message_center.requestResponse.msgType + ' was successful!'
								 	} 
								);
							break;
							case 'reject' :
								// send a message back to the fundraiser saying that the request has been rejected
								this.nextEvent = new MessageCenterEvent(
								 	MessageCenterEvent.MESSAGES_SEND, { 
								 		'action' : 'msg',
								 		'text' : _model.message_center.requestResponse.to_name + ' has rejected your ' + _model.message_center.requestResponse.msgType,
								 		'to_id' : _model.message_center.requestResponse.from_id,
								 		'subject' : _model.message_center.requestResponse.msgType + ' was denied!'
								 	} 
								);
							break;
						}
						
						this.executeNextCommand();
						this.nextEvent = null;
					}
					setSiteMsgs();
						
				break;	
			}
		}	
		private function onFault_deleteMessage(data:Object):void
		{
			if(_model.debug) Logger.info('deleteMessage Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}


		/**
		 * Search FundRaisers
		 */
		private function searchFundRaisers(event:MessageCenterEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchFundRaisers, onFault_searchFundRaisers);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			if(_model.debug){ Logger.info('searchFundRaisers Run', ObjectUtil.toString(event.obj)); }

			_model.dataLoading = true;
			
			delegate.searchFundRaisers( event.obj.searchTerm + '*', 0, event.obj.searchCount );
		}

		private function onResults_searchFundRaisers(data:Object):void 
		{
			if(_model.debug) Logger.info('searchFundRaisers Success', ObjectUtil.toString(data.result));
			
			var dp:ArrayCollection = new ArrayCollection();
			for each ( var item:Object in data.result[0].tr_users_details )
			{
				item['fullAddress'] = item._address1 + ', ' + item._city + ' ' + item._state;
				item['fullName'] = item.lname + ', ' + item.fname;
				item['label'] = item.lname + ', ' + item.fname;
				item['value'] = item.user_id;
				
				dp.addItem( item );
			}

			if(_model.debug) Logger.info('searchFundRaisers dataprovider', ObjectUtil.toString(dp));
			
			_model.message_center.fundraisersSearch = dp;

			_model.dataLoading = false;
		}	

		private function onFault_searchFundRaisers(data:Object):void
		{
			if(_model.debug){ Logger.info('searchFundRaisers Fault', ObjectUtil.toString(data.fault)); }	

			_model.dataLoading = false;
		}						




		/**
		 * SEND Message/Request
		 */
		private function sendMessage(event:MessageCenterEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_sendMessage, onFault_sendMessage);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			if(_model.debug) Logger.info('sendMessage Run', ObjectUtil.toString(event.obj));
			
			delegate.sendMessage( event.obj.to_id, event.obj.subject, event.obj.text, event.obj.action );
			_model.message_center.isSubmitting = true;
			_model.dataLoading = true;
		}
		
		private function onResults_sendMessage(data:Object):void 
		{
			if(_model.debug){ Logger.info('sendMessage Success', ObjectUtil.toString(data.result)); }

			switch(data.result.state)
			{
				case true :
					var successMsg:String = _model.message_center.requestResponse == null ?
						'That message has been sent successfully!' :
						'Your request response was successful! A message has been sent to the requesting fundraiser notifying of your decision';
				
					_model.message_center.errorVO = new ErrorVO( successMsg, 'successBox', true );

					_model.message_center.onClose = function():void
					{
						_model.message_center.isSubmitting = false;
					}
					
					// refresh the sent messages
					this.nextEvent = new MessageCenterEvent( MessageCenterEvent.MESSAGES_SENT );
					this.executeNextCommand();
					this.nextEvent = null;
				break;
				case false :				
					_model.message_center.errorVO = new ErrorVO( 
						data.result.error, 
						'errorBox', 
						true 
					);
					_model.my_contacts.onClose = function():void {
						_model.message_center.isSubmitting = false;
					}
				break;	
			}
			
			_model.dataLoading = false;
		}	
		
		private function onFault_sendMessage(data:Object):void
		{
			if(_model.debug) Logger.info('searchFundRaisers Fault', ObjectUtil.toString(data.fault));	

			_model.message_center.errorVO = new ErrorVO( 
				'There was a problem sending this message/request:', 
				'errorBox', 
				true 
			);
			
			_model.my_contacts.onClose = function():void {
				_model.message_center.isSubmitting = false;
			}

			_model.dataLoading = false;
		}		
		
						

		/**
		 * SEND Message/Request
		 */
		private function messageSent():void
		{			
			this.nextEvent = new MessageCenterEvent( MessageCenterEvent.MESSAGES_GET_SENT );
			this.executeNextCommand();
			this.nextEvent = null;
		}
							

		/**
		 * Search for fundraiser label
		 */
		private function searchLabel(event:MessageCenterEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchLabel, onFault_searchLabel);
			var delegate:MessageCenterDelegate = new MessageCenterDelegate(handlers);
			
			delegate.getUser( event.obj.userID );
		}
		private function onResults_searchLabel(data:Object):void 
		{
			if(_model.debug) Logger.info('search label Success', ObjectUtil.toString(data.result));
			
			if (data.result) 
				_model.message_center.fidLabel = data.result.tr_users_details[1].lname + ', ' + data.result.tr_users_details[1].fname;
		}	
		private function onFault_searchLabel(data:Object):void
		{
			if(_model.debug){ Logger.info('search label Fault', ObjectUtil.toString(data.fault)); }						
		}						


		/**
		 * Loop through the message and set a number of the unread messages
		 */
		private function setSiteMsgs():void
		{
			var toRead:uint = 0;
			for each( var item:Object in _model.message_center.messages)
			{				
				if (item.viewed == 0 || item.viewed == '0') toRead++;
			}
			_model.siteMsgs = toRead;
		}

		
	}
}