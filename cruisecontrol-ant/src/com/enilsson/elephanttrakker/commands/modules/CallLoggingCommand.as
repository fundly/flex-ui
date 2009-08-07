package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.models.Icons;
	import com.enilsson.elephanttrakker.business.*;
	import com.enilsson.elephanttrakker.events.modules.call_logging.*;
	import com.enilsson.elephanttrakker.events.modules.overview.*;
	import com.enilsson.elephanttrakker.events.session.SessionEvent;
	import com.enilsson.elephanttrakker.events.session.SessionFailEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.views.main.SupportForm;
	import com.enilsson.elephanttrakker.vo.*;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class CallLoggingCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function CallLoggingCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug) Logger.info('CallLogging Command', ObjectUtil.toString(event.type));
			
			switch(event.type)
			{
				case PledgeWorkspaceEvent.GET_CONTACT :
					getContactInfo(event as PledgeWorkspaceEvent);
				break;
				case PledgeWorkspaceEvent.GET_PLEDGE :
					getPledgeInfo(event as PledgeWorkspaceEvent);
				break;
				case PledgeWorkspaceEvent.LOOKUP_INPUT_SEARCH :
					lookupInputSearch(event as PledgeWorkspaceEvent);
				break;
				case PledgeWorkspaceEvent.GET_LABEL :
					searchLabel(event as PledgeWorkspaceEvent);
				break;
				case PledgeWorkspaceEvent.SAVE :
					savePledge(event as PledgeWorkspaceEvent);
				break;
				case PledgeWorkspaceEvent.DUP_SEARCH :
					checkDups(event as PledgeWorkspaceEvent);
				break;				
				case PledgeWorkspaceEvent.DO_TRANSACTION :
					doPledgeTransaction(event as PledgeWorkspaceEvent);
				break;				
				case PledgeWorkspaceEvent.SEND_EMAIL :
					sendEmail(event as PledgeWorkspaceEvent);
				break;	
				case PledgeWorkspaceEvent.DELETE_SAVED_PLEDGE :
					deleteSavedPledge(event as PledgeWorkspaceEvent);
				break;					
			}
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		

		/**
		 * Fetch Contact ID
		 */
		private function getContactInfo(event:PledgeWorkspaceEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getContactInfo, onFault_getContactInfo);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;
						
			delegate.get_contact( _model.call_logging.load_contact_id );
		}
		
		private function onResults_getContactInfo(data:Object):void 
		{
			if(_model.debug) Logger.info('Contact Success', ObjectUtil.toString(data.result) );
			
			_model.call_logging.initialContactData = data.result.contacts['1'];
			_model.call_logging.initialPledgeData = data.result.contacts['1'];
			
			_model.call_logging.transactionData = null;
			_model.call_logging.checkData = new Object();
			_model.call_logging.ccData = new Object();
			
			_model.call_logging.contactID = _model.call_logging.vo.contact.id;

			_model.call_logging.load_contact_id = 0;

			_model.dataLoading = false;
		}	
		
		private function onFault_getContactInfo(data:Object):void
		{
			if(_model.debug) Logger.info('Contact Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
			
			_model.call_logging.errorVO = new ErrorVO('There was a problem fetching this contacts details:<br><br>' + data.fault.faultString, 'errorBox', true);					
		}


		/**
		 * Fetch pledge ID
		 */
		private function getPledgeInfo(event:PledgeWorkspaceEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getPledgeInfo, onFault_getPledgeInfo);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
			_model.call_logging.formAction = 'edit';
			_model.call_logging.resetInitials = true;
			_model.call_logging.pledgeID = _model.call_logging.load_pledge_id;
			
			if(_model.debug) Logger.info('Loading Pledge ID', _model.call_logging.load_pledge_id);			
			
			var r:RecordVO = new RecordVO( 'pledges(transactions<ALL>,checks<ALL>)', _model.call_logging.load_pledge_id);			
			delegate.selectRecord( r );
		}
		
		private function onResults_getPledgeInfo(data:Object):void 
		{
			if(_model.debug) Logger.info('Loading Pledge Success', ObjectUtil.toString(data.result));

			// assign some variables
			var d:Object = data.result.pledges['1'];
			var t:ArrayCollection = new ArrayCollection();
			// list the contact ID
			_model.call_logging.contactID = d.contact_id;
			// assign the returned pledge data to the model
			_model.call_logging.initialContactData = d;
			_model.call_logging.initialPledgeData = d;
			
			var obj:Object = new Object();
			
			// add any check data to the transactions object
			if(d.hasOwnProperty('checks'))
			{
				if(d.checks['1'])
				{
					for ( var i:String in d.checks)
					{	
						obj = d.checks[i];
						obj['paymentType'] = 'Check';
						t.addItem(obj);				
					}
				}
			}
			// add any credit card data to the transactions object
			if(d.hasOwnProperty('transactions'))
			{
				if(d.transactions['1'])
				{
					for ( i in d.transactions)
					{	
						obj = d.transactions[i];
						obj['paymentType'] = 'Credit Card';
						t.addItem(obj);				
					}
				}
			}
			
			var sort:Sort = new Sort();
			sort.fields = [new SortField("created_on", true)];
			sort.reverse();
			t.sort = sort;
			t.refresh();
			
			
			// add the transactions data to the model
			_model.call_logging.transactionData = t;
			// clear the loading pledge variable	
			_model.call_logging.load_pledge_id = 0;
			// hide the data loading graphic
			_model.dataLoading = false;
			// initiate some validation once the data has been inserted
			_model.call_logging.runInit = true;

			if(_model.debug) Logger.info('Transaction Data', ObjectUtil.toString(_model.call_logging.transactionData));
		}
			
		private function onFault_getPledgeInfo(data:Object):void
		{
			if(_model.debug) Logger.info('Loading Pledge Fault', ObjectUtil.toString(data.fault), data.fault.faultCode);	
			
			_model.dataLoading = false;	
			
			// run the failed session event 
			this.nextEvent = new SessionFailEvent( data.fault.faultCode );
			this.executeNextCommand();
			this.nextEvent = null;							
		}


		/**
		 * Search for the LookupInput boxes
		 */
		private function lookupInputSearch(event:PledgeWorkspaceEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_lookupInputSearch, onFault_lookupInputSearch);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			var s:SearchVO = new SearchVO( event.params.table, event.params.searchTerm + '*', null, 0, event.params.searchCount );
			
			delegate.search( s );
		}
		private function onResults_lookupInputSearch(data:Object):void 
		{
			if(_model.debug) Logger.info('lookupInputSearch Success', ObjectUtil.toString(data.result));
			
			var dp:ArrayCollection = new ArrayCollection();
			var table:String = data.result['0'].table_name;
			var item:Object;
			
			switch(table)
			{
				case 'events' :
					for each ( item in data.result['0'].events )
					{
						item['value'] = item.id;				
						item['label'] = item.source_code;								
						dp.addItem( item );
					}
					
					_model.call_logging.sourceCodeSearch = dp;
				break;
				case 'tr_users_details' :
					for each ( item in data.result['0'].tr_users_details )
					{
						item['value'] = item.user_id;				
						item['label'] = item.lname + ', ' + item.fname;								
						dp.addItem( item );
					}
					
					if(_model.debug) Logger.info('fidSearch', ObjectUtil.toString(dp));
					
					_model.call_logging.fidSearch = dp;
				break;
			}
		}	
		private function onFault_lookupInputSearch(data:Object):void
		{
			if(_model.debug) Logger.info('lookupInputSearch Fault', ObjectUtil.toString(data.fault));
					
			// run the failed session event 
			this.nextEvent = new SessionFailEvent( data.fault.faultCode );
			this.executeNextCommand();
			this.nextEvent = null;							
		}			
		
		
		/**
		 * Search for event label
		 */
		private function searchLabel(event:PledgeWorkspaceEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchLabel, onFault_searchLabel);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			if (event.params.eventID != 0)
				delegate.selectRecord( new RecordVO(event.params.table, event.params.id ) );
		}
		
		private function onResults_searchLabel(data:Object):void 
		{
			if(_model.debug) Logger.info('search label Success', ObjectUtil.toString(data.result));
			
			if (data.result) 
			{
				var label:String = "";
				switch(data.result.table_name)
				{
					case 'events':
						_model.call_logging.eventsLabel = data.result.events[1].source_code;
					break;
					case 'tr_users_details':
						_model.call_logging.tr_usersLabel = data.result.tr_users_details[1].lname + ', ' + data.result.tr_users_details[1].fname;
					break;
				}
			}			
		}	
		
		private function onFault_searchLabel(data:Object):void
		{
			if(_model.debug){ Logger.info('search label Fault', ObjectUtil.toString(data.fault)); }	
		
			// run the failed session event 
			this.nextEvent = new SessionFailEvent( data.fault.faultCode );
			this.executeNextCommand();
			this.nextEvent = null;							
		}						
	

		/**
		 * Save the pledge to be worked on later
		 */			
		private function savePledge(event:PledgeWorkspaceEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_savePledge, onFault_savePledge);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.call_logging.formProcessing = true;
			
			delegate.upsertRecord( new RecordVO( 'user_storage', 0, '', event.params ) );
		}
				
		private function onResult_savePledge(event:Object):void 
		{
			if(_model.debug) Logger.info('savePledge Success', ObjectUtil.toString(event.result));
		
			// hide the form processing indicator
			_model.call_logging.formProcessing = false;	
			
			switch(event.result.state)
			{
				case '99' :
				case '98' :
					_model.call_logging.errorVO = new ErrorVO( 'This pledge was successfully saved', 'successBox', true );
					_model.call_logging.savedID = event.result.details;
					
					// refresh the list of saved pledges on the MyHistory screen
					_model.my_history.initSavedCalls = true;
				break;
				case '-99' :
					var eMsg:String = 'There was a problem processing this record:<br><br>';
					if(typeof(event.result.errors) == 'string')
						eMsg += event.result.errors;
					else
						for(var i:String in event.result.errors)
							eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.call_logging.errorVO = new ErrorVO( eMsg, 'errorBox', true );
				break;	
			}
		}
		
		private function onFault_savePledge(event:Object):void
		{
			if(_model.debug) Logger.info('savePledge', ObjectUtil.toString(event));		
		
			// hide the form processing indicator
			_model.call_logging.formProcessing = false;	
			
			// run the failed session event 
			this.nextEvent = new SessionFailEvent( event.fault.faultCode );
			this.executeNextCommand();
			this.nextEvent = null;							
		}	


		/**
		 * Check the entered information for the presence of duplicates
		 */
		private function checkDups(event:PledgeWorkspaceEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_checkDups, onFault_checkDups);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_model.call_logging.formProcessing = true;
			
 			var s:SearchVO;

			switch(event.params.table)
			{
				case 'contacts' :
					var c:Object = _model.call_logging.vo.contact;
					s = new SearchVO(
						'contacts',
						c.lname + ' ' + c.fname.substr(0,3) + '* ' + c.city + ' ' + c.zip + ' ' + c.email
					);
				break;
				case 'pledges' :
					var p:Object = _model.call_logging.vo.pledge;
					s = new SearchVO(
						'pledges',
						p.lname + ' ' + p.fname.substr(0,3) + '* ' + p.city + ' ' + p.zip + ' ' + p.email + ' ' + p.pledge_amount
					);
				break;				
			}
			
			if(_model.debug) Logger.info('Dup Check', event.params.table, ObjectUtil.toString(s));
			
			delegate.search( s );
		}
		
		private function onResults_checkDups(data:Object):void 
		{
			if(_model.debug) Logger.info('checkDups Success', ObjectUtil.toString(data.result[0]));
			
			var item:Object;
			var tableName:String = data.result[0].table_name;
			
			switch (tableName)
			{
				case 'contacts' :
					if(data.result[0].hasOwnProperty('contacts'))
					{	
						_model.call_logging.contactDups.removeAll();
						
						for each ( item in data.result[0].contacts )
							_model.call_logging.contactDups.addItem(item);
							
						_model.call_logging.formProcessing = false;	
						_model.call_logging.dupsVStack = 0;
						_model.call_logging.showDupBox = true;
					}
					else
					{
						this.nextEvent = new PledgeWorkspaceEvent ( PledgeWorkspaceEvent.DUP_SEARCH, { table : 'pledges' } );
						this.executeNextCommand();
						this.nextEvent = null;
					}
				break;
				case 'pledges' :
					if(data.result[0].hasOwnProperty('pledges'))
					{	
						_model.call_logging.pledgeDups = new Array();
						
						for each ( item in data.result[0].pledges )
							_model.call_logging.pledgeDups.push(item);
						
						_model.call_logging.formProcessing = false;
						_model.call_logging.dupsVStack = 1;	
						_model.call_logging.showDupBox = true;
					}
					else
					{
						this.nextEvent = new PledgeWorkspaceEvent ( PledgeWorkspaceEvent.DO_TRANSACTION );
						this.executeNextCommand();
						this.nextEvent = null;
					}							
				break;
			}
		}	
		
		private function onFault_checkDups(data:Object):void
		{
			if(_model.debug) Logger.info('checkDups Fault', ObjectUtil.toString(data.fault));
					
			// run the failed session event 
			this.nextEvent = new SessionFailEvent( data.fault.faultCode );
			this.executeNextCommand();
			this.nextEvent = null;							
		}						


		/**
		 * Pass the PledgeVO for transaction
		 */
		private function doPledgeTransaction(event:PledgeWorkspaceEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_doPledgeTransaction, onFault_doPledgeTransaction);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			if(_model.debug) Logger.info('doPledgeTransaction Start', ObjectUtil.toString(_model.call_logging.vo));

   			_model.call_logging.formProcessing = true;
			
 			delegate.process_pledge ( _model.call_logging.vo );
		}
		
		private function onResults_doPledgeTransaction(event:Object):void 
		{
			if(_model.debug) Logger.info('doPledgeTransaction Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			_model.call_logging.formProcessing = false;
			
			switch(event.result.state)
			{
				case 98 :
				case 99 :
					// send an email if there is a contribution
					if ( _model.call_logging.vo.check != null || _model.call_logging.vo.transaction != null ) 
					{
						var df:DateFormatter = new DateFormatter();
						df.formatString = 'MM/DD/YYYY';
						var cf:CurrencyFormatter = new CurrencyFormatter();
						
						var params:Object = _model.call_logging.vo.pledge;
						params['date'] = df.format(new Date());
						params['pledge_amount'] = _model.call_logging.vo.check == null ? 
							cf.format(_model.call_logging.vo.transactionData.amount) :  
							cf.format(_model.call_logging.vo.check.amount);
						
						// send an email thanking the user for a credit card transaction
						if(_model.call_logging.vo.transaction != null)
						{						
							// add the transaction data, unfortunately you cant loop through a typed object (WTF??)
							params['card_type'] = _model.call_logging.vo.transaction.card_type;
							params['card_number'] = _model.call_logging.vo.transaction.card_number;
							params['amount'] = _model.call_logging.vo.transaction.amount;
							params['full_name'] = _model.call_logging.vo.transaction.full_name;
							params['fname'] = _model.call_logging.vo.transaction.fname;
							params['lname'] = _model.call_logging.vo.transaction.lname;
							params['address'] = _model.call_logging.vo.transaction.address;
							params['address2'] = _model.call_logging.vo.transaction.address2;
							params['city'] = _model.call_logging.vo.transaction.city;
							params['state'] = _model.call_logging.vo.transaction.state;
							params['zip'] = _model.call_logging.vo.transaction.zip;
							
							// format the amount
							params.amount = cf.format(params.amount);
								
							// obfuscate the cc number
							params.card_number = 'XXXXXXXXXXXX' + params.card_number.substr(-4,4);
							
							// add the transaction ID
							params['transactionID'] = event.result.details[2];
							
							if(_model.debug) Logger.info('Email Params - CC contribution', params);
							
							// send the email with the params set
							this.nextEvent = new PledgeWorkspaceEvent(
								PledgeWorkspaceEvent.SEND_EMAIL, 
								{
									'emails' : _model.call_logging.vo.pledge.email, //'james@enilsson.com', 
									'message' : '',
									'template_id' : _model.serverVariables.pledge_template_id,
									'template_vars' : params,
									'attachments' : ''
								}
							);
							this.executeNextCommand();
							this.nextEvent = null;
						}
						// email for check contribution
						else
						{
							// check to see that the user wants to send out an email
							if( _model.call_logging.vo.check.form_send == 'email')
							{
								if(_model.debug) Logger.info('Email Params - Check contribution', params);								
															
								this.nextEvent = new PledgeWorkspaceEvent(
									PledgeWorkspaceEvent.SEND_EMAIL, 
									{
										'emails' : _model.call_logging.vo.check.email, //'james@enilsson.com', 
										'message' : '',
										'template_id' : _model.serverVariables.donation_form_template_id,
										'template_vars' : params,
										'attachments' : ''
									}
								);
								this.executeNextCommand();
								this.nextEvent = null;
							}
						}

						
						if(_model.call_logging.formAction == 'edit')
						{
							_model.call_logging.reset();
	
							// set the transaction vstack to the payments list
							_model.call_logging.vindex = 1;
							_model.call_logging.transVStack = 2;
							_model.call_logging.load_pledge_id = event.result.details[0];
							
							this.nextEvent = new PledgeWorkspaceEvent( PledgeWorkspaceEvent.GET_PLEDGE );
							this.executeNextCommand();
							this.nextEvent = null;		
						}
					}				
				
				
					if (_model.call_logging.formAction == 'add') 
					{
						// add the contact to the selected email if it decided to add it to 
						if(event.result.details[1])
							_model.call_logging.contactID = event.result.details[1]; 

						// set pledge to completed in case it just got added for the first time
						_model.call_logging.completedPledge = (_model.call_logging.formAction == 'add');
					} 
					else 
						_model.call_logging.errorVO = new ErrorVO( 'This contribution was processed successfully', 'successBox', true );
	

					//update the list of pledges in MyHistory
					_model.my_history.initPledges = true;
					// trigger an update for the QuickStats screen in MyHistory
					_model.my_history.initQuickStats = true;
					// update for contributions
					_model.my_history.initContributions = true;
					
					// update the session information so that the statistics get updated.
					new SessionEvent( SessionEvent.GET_SESSION_INFO ).dispatch();
					
					
				break;
				case -99 :
					// record the number of attempts
					_model.call_logging.transactionAttempts++;
					
					var eMsg:String = 'There was a problem processing this pledge:<br><br>';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
					
					// add a message to tell the user they have made too many attempts	
					if(_model.call_logging.transactionAttempts > 4)
						eMsg += '<br>You have now made <b>' + _model.call_logging.transactionAttempts + '</b> attempts to process this pledge. It might be a good idea to save the pledge and make a support call for assistance.'
						
					_model.call_logging.errorVO = new ErrorVO( eMsg, 'errorBox', true );
				break;
			}
		}	
		
		private function onFault_doPledgeTransaction(event:Object):void
		{
			if(_model.debug) Logger.info('doPledgeTransaction Fault', ObjectUtil.toString(event.fault));
			
			_model.call_logging.formProcessing = false;
			
			switch( event.fault.faultCode )
			{
				case 'Client.Error.RequestTimeout' :
					_model.call_logging.errorVO = new ErrorVO( 
						'Unfortunately your request to process this card has timed out.<br><br>Please <b>SAVE</b> your pledge to process it at a later date. Sorry for the inconvenience',
						'errorBox', 
						true 
					);
				break;
				case 'AMFPHP_RUNTIME_ERROR' :
					_model.supportDescription = event.fault.faultString;
					Alert.show(	
					'There was an error during processing. Please complete a support ticket, and send any relevant information that may help in resolving this issue',
						'Processing error', 
						0, 
						null,
						function():void{
							var sClass:Class = SupportForm as Class;	 	
							var sp:* = PopUpManager.createPopUp( _model.mainScreen, sClass, true );
							PopUpManager.centerPopUp(sp);
						},
						Icons.ALERT
					);
				break;
			}
		}


		/**
		 * Send an email on success of the pledge transaction
		 */
		private function sendEmail(event:PledgeWorkspaceEvent):void
		{
			if(_model.debug) Logger.info('Sending Email', event.params);

			var handlers:IResponder = new mx.rpc.Responder(onResults_sendEmail, onFault_sendEmail);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.send_system_email(event.params);
		}
		
		private function onResults_sendEmail(event:Object):void 
		{
			if(_model.debug) Logger.info('Sent Email Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			_model.call_logging.formProcessing = false;
		
		}
			
		private function onFault_sendEmail(event:Object):void
		{
			if(_model.debug) Logger.info('Sent Email Fault', ObjectUtil.toString(event.fault));	
			
			_model.dataLoading = false;	
			_model.call_logging.formProcessing = true;
		}

		
		/**
		 * Delete a savedpledge
		 */
		private function deleteSavedPledge(event:PledgeWorkspaceEvent):void
		{
			if (_model.debug) Logger.info('Delete a Saved Pledge');
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteSavedPledge, onFault_deleteSavedPledge);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			delegate.deleteRecord( new RecordVO('user_storage', event.params.id ) );
		}

		private function onResults_deleteSavedPledge(event:Object):void 
		{
			if(_model.debug) Logger.info('deleteSavedPledge Success', ObjectUtil.toString(event.result));
			
			// update for saved calls in the my history
			_model.my_history.initSavedCalls = true;
		}	

		private function onFault_deleteSavedPledge(event:Object):void
		{
			if(_model.debug) Logger.info('deleteSavedPledge Fault', ObjectUtil.toString(event.fault));
			
			_model.dataLoading = false;
		}			

	}
}