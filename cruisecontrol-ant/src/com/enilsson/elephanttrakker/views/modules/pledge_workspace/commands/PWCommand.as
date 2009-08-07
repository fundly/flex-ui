package com.enilsson.elephanttrakker.views.modules.pledge_workspace.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.models.Icons;
	import com.enilsson.elephanttrakker.business.*;
	import com.enilsson.elephanttrakker.events.modules.overview.*;
	import com.enilsson.elephanttrakker.events.session.*;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.views.main.SupportForm;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.events.*;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.model.*;
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


	public class PWCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		private var _presentationModel:PledgeWorkspaceModel;
		
		public function PWCommand() { }

		override public function execute( event:CairngormEvent ):void
		{
			_presentationModel = PWEvent(event).model;

			if(_presentationModel.debug) Logger.info('PledgeWorkspace Command', event.type );
			
			switch(event.type)
			{
				case PWEvent.GET_PLEDGE :
					getPledgeInfo(event as PWEvent);
				break;
				case PWEvent.GET_CONTACT :
					getContactInfo(event as PWEvent);
				break;
				case PWEvent.LOOKUP_INPUT_SEARCH :
					lookupInputSearch(event as PWEvent);
				break;
				case PWEvent.GET_LABEL :
					searchLabel(event as PWEvent);
				break;
				case PWEvent.SAVE :
					savePledge(event as PWEvent);
				break;
				case PWEvent.DUP_SEARCH :
					checkDups(event as PWEvent);
				break;				
				case PWEvent.DO_TRANSACTION :
					doPledgeTransaction(event as PWEvent);
				break;				
				case PWEvent.SEND_EMAIL :
					sendEmail(event as PWEvent);
				break;	
				case PWEvent.DELETE_SAVED_PLEDGE :
					deleteSavedPledge(event as PWEvent);
				break;					
			}
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		

		/**
		 * Fetch pledge ID
		 */
		private function getPledgeInfo( event:PWEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getPledgeInfo, onFault_getPledgeInfo);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
			
			if(_presentationModel.debug) Logger.info('Loading Pledge ID', event.params.pledgeID );			
			
			var r:RecordVO = new RecordVO( 'pledges(transactions<ALL>,checks<ALL>)', event.params.pledgeID );			
			delegate.selectRecord( r );
		}
		
		private function onResults_getPledgeInfo(data:Object):void 
		{
			if(_presentationModel.debug) Logger.info('Loading Pledge Success', ObjectUtil.toString(data.result));

			// assign some variables
			var d:Object = data.result.pledges['1'];
			var t:ArrayCollection = new ArrayCollection();
			
			// list the contact ID
			_presentationModel.contactID = d.contact_id;
			
			// assign the returned pledge data to the model
			_presentationModel.initialContactData = d;
			_presentationModel.initialPledgeData = d;
			
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
			
			// sort the data by created_on date
			var sort:Sort = new Sort();
			sort.fields = [new SortField("created_on", true)];
			sort.reverse();
			t.sort = sort;
			t.refresh();
			
			// add the transactions data to the model
			_presentationModel.contributions = t;

			// hide the data loading graphic
			_model.dataLoading = false;

			if(_presentationModel.debug) Logger.info('Transaction Data', ObjectUtil.toString(_presentationModel.contributions));
		}
			
		private function onFault_getPledgeInfo(data:Object):void
		{
			if(_presentationModel.debug) Logger.info('Loading Pledge Fault');	
		}


		/**
		 * Fetch Contact information
		 */
		private function getContactInfo( event:PWEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getContactInfo, onFault_getContactInfo);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;
			
			//if(_presentationModel.debug) 
			Logger.info('Loading Contact ID', event.params.contactID );
						
			delegate.get_contact( event.params.contactID );
		}
		
		private function onResults_getContactInfo( event:Object ):void 
		{
			if(_presentationModel.debug) Logger.info('Contact Success', ObjectUtil.toString(event.result) );
			
			var contactData:Object = event.result.contacts['1'];
			
			_presentationModel.initialContactData = contactData;
			_presentationModel.initialPledgeData = contactData;
			
			_model.dataLoading = false;
		}	
		
		private function onFault_getContactInfo( event:Object ):void
		{
			if(_presentationModel.debug) Logger.info('Contact Fault', ObjectUtil.toString( event.fault ) );	
			
			_model.dataLoading = false;			
			
			_presentationModel.errorVO = new ErrorVO(
				'There was a problem fetching this contacts details:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true
			);					
		}


		/**
		 * Search for the LookupInput boxes
		 */
		private function lookupInputSearch( event:PWEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_lookupInputSearch, onFault_lookupInputSearch);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			var s:SearchVO = new SearchVO( event.params.table, event.params.searchTerm + '*', null, 0, event.params.searchCount );
			
			delegate.search( s );
		}
		
		private function onResults_lookupInputSearch(data:Object):void 
		{
			if(_presentationModel.debug) Logger.info('lookupInputSearch Success', ObjectUtil.toString(data.result));
			
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
					
					_presentationModel.sourceCodeSearch = dp;
				break;
				case 'tr_users_details' :
					for each ( item in data.result['0'].tr_users_details )
					{
						item['value'] = item.user_id;				
						item['label'] = item.lname + ', ' + item.fname;								
						dp.addItem( item );
					}
					
					if(_model.debug) Logger.info('fidSearch', ObjectUtil.toString(dp));
					
					_presentationModel.fidSearch = dp;
				break;
			}
		}	
		
		private function onFault_lookupInputSearch(data:Object):void
		{
			if(_presentationModel.debug) Logger.info('lookupInputSearch Fault');
		}			
		
		
		/**
		 * Search for event label
		 */
		private function searchLabel(event:PWEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchLabel, onFault_searchLabel);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			if (event.params.eventID != 0)
				delegate.selectRecord( new RecordVO(event.params.table, event.params.id ) );
		}
		
		private function onResults_searchLabel(data:Object):void 
		{
			if(_presentationModel.debug) Logger.info('search label Success', ObjectUtil.toString(data.result));
			
			if (data.result) 
			{
				var label:String = "";
				switch(data.result.table_name)
				{
					case 'events':
						_presentationModel.eventsLabel = data.result.events[1].source_code;
					break;
					case 'tr_users_details':
						_presentationModel.tr_usersLabel = data.result.tr_users_details[1].lname + ', ' + data.result.tr_users_details[1].fname;
					break;
				}
			}			
		}	
		
		private function onFault_searchLabel(data:Object):void
		{
			if(_presentationModel.debug) Logger.info('search label Fault');
		}						
	

		/**
		 * Save the pledge to be worked on later
		 */			
		private function savePledge(event:PWEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_savePledge, onFault_savePledge);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_presentationModel.formProcessing = true;
			
			delegate.upsertRecord( new RecordVO( 'user_storage', 0, '', event.params ) );
		}
				
		private function onResult_savePledge(event:Object):void 
		{
			if(_presentationModel.debug) Logger.info('savePledge Success', ObjectUtil.toString(event.result));
		
			// hide the form processing indicator
			_presentationModel.formProcessing = false;	
			
			switch(event.result.state)
			{
				case '99' :
				case '98' :
					_presentationModel.errorVO = new ErrorVO( 'This pledge was successfully saved', 'successBox', true );
					_presentationModel.savedID = event.result.details;
					
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
						
					_presentationModel.errorVO = new ErrorVO( eMsg, 'errorBox', true );
				break;	
			}
		}
		
		private function onFault_savePledge(event:Object):void
		{
			if(_presentationModel.debug) Logger.info('savePledge');		
		
			// hide the form processing indicator
			_presentationModel.formProcessing = false;	
		}	


		/**
		 * Check the entered information for the presence of duplicates
		 */
		private function checkDups(event:PWEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_checkDups, onFault_checkDups);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			_presentationModel.formProcessing = true;
			
 			var s:SearchVO;

			switch(event.params.table)
			{
				case 'pledges' :
					var p:Object = _presentationModel.pledgeData;
					s = new SearchVO(
						'pledges',
						p.lname + ' ' + p.fname.substr(0,3) + '* ' + p.city + ' ' + p.zip + ' ' + p.email + ' ' + p.pledge_amount
					);
				break;				
			}
			
			if(_presentationModel.debug) Logger.info('Dup Check', event.params.table, ObjectUtil.toString(s));
			
			delegate.search( s );
		}
		
		private function onResults_checkDups(data:Object):void 
		{
			if(_presentationModel.debug) Logger.info('checkDups Success', ObjectUtil.toString(data.result[0]));
			
			var item:Object;
			var tableName:String = data.result[0].table_name;
			
			switch (tableName)
			{
				case 'pledges' :
					if(data.result[0].hasOwnProperty('pledges'))
					{	
						_model.call_logging.pledgeDups = new Array();
						
						for each ( item in data.result[0].pledges )
							_presentationModel.pledgeDups.push(item);
						
						_presentationModel.formProcessing = false;
						_presentationModel.dupsVStack = 1;	
						_presentationModel.showDupBox = true;
					}
					else
					{
						this.nextEvent = new PWEvent ( PWEvent.DO_TRANSACTION, _presentationModel );
						this.executeNextCommand();
						this.nextEvent = null;
					}							
				break;
			}
		}	
		
		private function onFault_checkDups(data:Object):void
		{
			if(_presentationModel.debug) Logger.info('checkDups Fault');
		}						


		/**
		 * Pass the PledgeVO for transaction
		 */
		private function doPledgeTransaction( event:PWEvent ):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_doPledgeTransaction, onFault_doPledgeTransaction);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			if(_presentationModel.debug) Logger.info('doPledgeTransaction Start', ObjectUtil.toString( event.params.vo ));

   			_presentationModel.formProcessing = true;
			
 			delegate.process_pledge ( event.params.vo );
		}
		
		private function onResults_doPledgeTransaction(event:Object):void 
		{
			if(_presentationModel.debug) Logger.info('doPledgeTransaction Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			_presentationModel.formProcessing = false;
			
			switch(event.result.state)
			{
				case 98 :
				case 99 :
					// send an email if there is a contribution
					if ( _presentationModel.vo.check != null || _presentationModel.vo.transaction != null ) 
					{
						var df:DateFormatter = new DateFormatter();
						df.formatString = 'MM/DD/YYYY';
						var cf:CurrencyFormatter = new CurrencyFormatter();
						
						var params:Object = _presentationModel.vo.pledge;
						params['date'] = df.format(new Date());
						params['pledge_amount'] = _presentationModel.vo.check == null ? 
							cf.format(_presentationModel.vo.transactionData.amount) :  
							cf.format(_presentationModel.vo.check.amount);
						
						// send an email thanking the user for a credit card transaction
						if(_presentationModel.vo.transaction != null)
						{						
							// add the transaction data, unfortunately you cant loop through a typed object (WTF??)
							params['card_type'] = _presentationModel.vo.transaction.card_type;
							params['card_number'] = _presentationModel.vo.transaction.card_number;
							params['amount'] = _presentationModel.vo.transaction.amount;
							params['full_name'] = _presentationModel.vo.transaction.full_name;
							params['fname'] = _presentationModel.vo.transaction.fname;
							params['lname'] = _presentationModel.vo.transaction.lname;
							params['address'] = _presentationModel.vo.transaction.address;
							params['address2'] = _presentationModel.vo.transaction.address2;
							params['city'] = _presentationModel.vo.transaction.city;
							params['state'] = _presentationModel.vo.transaction.state;
							params['zip'] = _presentationModel.vo.transaction.zip;
							
							// format the amount
							params.amount = cf.format(params.amount);
								
							// obfuscate the cc number
							params.card_number = 'XXXXXXXXXXXX' + params.card_number.substr(-4,4);
							
							// add the transaction ID
							params['transactionID'] = event.result.details[2];
							
							if(_presentationModel.debug) Logger.info('Email Params - CC contribution', params);
							
							// send the email with the params set
							this.nextEvent = new PWEvent(
								PWEvent.SEND_EMAIL, 
								_presentationModel,
								{
									'emails' : _presentationModel.vo.pledge.email, //'james@enilsson.com', 
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
							if( _presentationModel.vo.check.form_send == 'email')
							{
								if(_presentationModel.debug) Logger.info('Email Params - Check contribution', params);								
															
								this.nextEvent = new PWEvent(
									PWEvent.SEND_EMAIL, 
									_presentationModel,
									{
										'emails' : _presentationModel.vo.check.email, //'james@enilsson.com', 
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

						
						if(_presentationModel.action == PledgeWorkspaceModel.EDIT)
						{
							_presentationModel.reset();
	
							// set the transaction vstack to the payments list
							_presentationModel.vindex = 1;
							_presentationModel.transVStack = 2;
							
							this.nextEvent = new PWEvent( 
								PWEvent.GET_PLEDGE, 
								_presentationModel, 
								{ pledgeID: event.result.details[0] } 
							);
							this.executeNextCommand();
							this.nextEvent = null;		
						}
					}				
				
				
					if (_presentationModel.action != PledgeWorkspaceModel.EDIT) 
					{
						// add the contact to the selected email if it decided to add it to 
						if(event.result.details[1])
							_presentationModel.contactID = event.result.details[1]; 

						// set pledge to completed in case it just got added for the first time
						_presentationModel.completedPledge = (_presentationModel.action != PledgeWorkspaceModel.EDIT);
					} 
					else 
						_presentationModel.errorVO = new ErrorVO( 'This contribution was processed successfully', 'successBox', true );
	

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
					_presentationModel.transactionAttempts++;
					
					var eMsg:String = 'There was a problem processing this pledge:<br><br>';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
					
					// add a message to tell the user they have made too many attempts	
					if(_presentationModel.transactionAttempts > 4)
						eMsg += '<br>You have now made <b>' + _presentationModel.transactionAttempts + '</b> attempts to process this pledge. It might be a good idea to save the pledge and make a support call for assistance.'
						
					_presentationModel.errorVO = new ErrorVO( eMsg, 'errorBox', true );
				break;
			}
		}	
		
		private function onFault_doPledgeTransaction(event:Object):void
		{
			if(_presentationModel.debug) Logger.info('doPledgeTransaction Fault', ObjectUtil.toString(event.fault));
			
			_presentationModel.formProcessing = false;
			
			switch( event.fault.faultCode )
			{
				case 'Client.Error.RequestTimeout' :
					_presentationModel.errorVO = new ErrorVO( 
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
		private function sendEmail(event:PWEvent):void
		{
			if(_presentationModel.debug) Logger.info('Sending Email', event.params);

			var handlers:IResponder = new mx.rpc.Responder(onResults_sendEmail, onFault_sendEmail);
			var delegate:PluginsDelegate = new PluginsDelegate(handlers);
			
			_model.dataLoading = true;

			delegate.send_system_email(event.params);
		}
		
		private function onResults_sendEmail(event:Object):void 
		{
			if(_presentationModel.debug) Logger.info('Sent Email Success', ObjectUtil.toString(event.result));

			_model.dataLoading = false;
			_presentationModel.formProcessing = false;
		
		}
			
		private function onFault_sendEmail(event:Object):void
		{
			if(_presentationModel.debug) Logger.info('Send Email Fault');	
			
			_presentationModel.formProcessing = true;
		}

		
		/**
		 * Delete a savedpledge
		 */
		private function deleteSavedPledge(event:PWEvent):void
		{
			if (_presentationModel.debug) Logger.info('Delete a Saved Pledge');
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteSavedPledge, onFault_deleteSavedPledge);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			delegate.deleteRecord( new RecordVO('user_storage', event.params.id ) );
		}

		private function onResults_deleteSavedPledge(event:Object):void 
		{
			if(_presentationModel.debug) Logger.info('deleteSavedPledge Success', ObjectUtil.toString(event.result));
			
			// update for saved calls in the my history
			_model.my_history.initSavedCalls = true;
		}	

		private function onFault_deleteSavedPledge(event:Object):void
		{
			if(_presentationModel.debug) Logger.info('deleteSavedPledge Fault');
		}			

	}
}