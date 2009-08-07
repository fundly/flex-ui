package com.enilsson.elephantadmin.commands.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.SearchDelegate;
	import com.enilsson.elephantadmin.events.modules.PledgeEvent;
	import com.enilsson.elephantadmin.views.modules.pledges.model.PledgesModel;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class PledgesCommand extends RecordModuleCommand
	{
		private var _pledgesModel:PledgesModel;

		public function PledgesCommand()
		{
			super();
			_moduleName = 'Pledges';
		}
		
		override public function execute(event:CairngormEvent):void
		{
			super.execute(event);

			_pledgesModel = PledgesModel(_presentationModel);

			switch(event.type)
			{
				case PledgeEvent.GET_CONTRIBUTIONS :
					getContributions( event as PledgeEvent );
				break;	
				case PledgeEvent.LOOKUPINPUT_SEARCH :
					lookupInputSearch( event as PledgeEvent );
				break;
				case PledgeEvent.GET_LABEL :
					searchLabel( event as PledgeEvent );
				break;
				case PledgeEvent.UPSERT_CHECKREFUND :
					upsertCheckRefund( event as PledgeEvent );
				break;
				case PledgeEvent.DELETE_CHECKREFUND :
					deleteRefund( event as PledgeEvent );
				break;
			}
		}


		private function getContributions(event:PledgeEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getContributions, onFault_getContributions);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			if(_model.debug) Logger.info(_moduleName + ' getContributions Call', ObjectUtil.toString(event.recordVO));

			_model.dataLoading = true;

			delegate.selectRecord( event.recordVO );
		}
		
		private function onResults_getContributions(event:ResultEvent):void 
		{
			if(_model.debug) Logger.info('Loading Contributions Success', ObjectUtil.toString(event.result));

			// assign some variables
			var d:Object = event.result.pledges['1'];
			var t:ArrayCollection = new ArrayCollection();
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
			// add any paypal data to the transactions object
			if(d.hasOwnProperty('paypal_transactions'))
			{
				if(d.paypal_transactions['1'])
				{
					for ( i in d.paypal_transactions)
					{	
						obj = d.paypal_transactions[i];
						obj['paymentType'] = 'PayPal';
						t.addItem(obj);
					}
				}
			}			
			
			var sort:Sort = new Sort();
			sort.fields = [new SortField("created_on", true)];
			sort.reverse();
			t.sort = sort;
			t.refresh();
			
			_pledgesModel.contributions = t;
			
			// hide the data loading graphic
			_model.dataLoading = false;
			_pledgesModel.contributionsTabLoading = false;
		}
			
		private function onFault_getContributions(event:FaultEvent):void
		{
			if(_model.debug) Logger.info('Loading Contributions Fault', ObjectUtil.toString(event.fault), event.fault.faultCode);
			
			_model.dataLoading = false;

			_model.errorVO = new ErrorVO( 
				'There was a problem loading contributions from this user:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}


		/**
		 * Search for the LookupInput boxes
		 */
		private function lookupInputSearch( event:PledgeEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_lookupInputSearch, onFault_lookupInputSearch);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			delegate.search( event.searchVO );
		}
		
		private function onResults_lookupInputSearch( event:ResultEvent ):void 
		{
			if(_model.debug) Logger.info('lookupInputSearch Success', ObjectUtil.toString(event.result));
			
			var dp:ArrayCollection = new ArrayCollection();
			var table:String = event.result['0'].table_name;
			var item:Object;
			
			switch(table)
			{
				case 'events' :
					for each ( item in event.result['0'].events )
					{
						item['value'] = item.id;				
						item['label'] = item.source_code;								
						dp.addItem( item );
					}
					
					_pledgesModel.sourceCodeSearch = dp;
				break;
				case 'tr_users_details' :
					for each ( item in event.result['0'].tr_users_details )
					{
						item['value'] = item.user_id;				
						item['label'] = item.lname + ', ' + item.fname;								
						dp.addItem( item );
					}
					
					_pledgesModel.fidSearch = dp;
				break;
			}
		}	
		
		private function onFault_lookupInputSearch( event:FaultEvent ):void
		{
			if(_model.debug) Logger.info('lookupInputSearch Fault', ObjectUtil.toString(event.fault));
			_model.errorVO = new ErrorVO( 
				'There was a problem searching the Lookup List:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}


		/**
		 * Search for event label
		 */
		private function searchLabel( event:PledgeEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchLabel, onFault_searchLabel);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			delegate.selectRecord( event.recordVO );
		}
		
		private function onResults_searchLabel( event:ResultEvent ):void 
		{
			if(_pledgesModel.debug) Logger.info('Search label Success', ObjectUtil.toString(event.result));
			
			if ( event.result ) 
			{
				var label:String = "";
				switch(event.result.table_name)
				{
					case 'events':
						_pledgesModel.eventsLabel = event.result.events[1].source_code;
					break;
					case 'tr_users_details':
						_pledgesModel.tr_usersLabel = event.result.tr_users_details[1].lname + ', ' + event.result.tr_users_details[1].fname;
					break;
				}
			}			
		}	
		
		private function onFault_searchLabel(event:FaultEvent):void
		{
			if(_pledgesModel.debug) Logger.info('Search label Fault', ObjectUtil.toString(event.fault));
			_model.errorVO = new ErrorVO( 
				'There was a problem loading the Lookup List:<br><br>' + event.fault.faultString, 
				'errorBox', 
				true 
			);
		}

		/**
		 * Upsert a check refund
		 */
		private function upsertCheckRefund( event:PledgeEvent ):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_upsertCheckRefund, onFault_upsertCheckRefund);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
			
			delegate.upsertRecord( event.recordVO );
		}
		
		private function onResults_upsertCheckRefund( event:Object ):void 
		{
			if(_pledgesModel.debug) Logger.info('upsertCheckRefund Success', ObjectUtil.toString(event.result));
			
			_model.dataLoading = false;

			switch(event.result.state)
			{
				case '99' :
				case '98' :
					_pledgesModel.refundError = new ErrorVO( 'Check refund added successfully!', 'successBox', true );
					
					// refresh the search list
					_presentationModel.lastQuery.dispatch();
					_presentationModel.searchListSelectedIndex = _presentationModel.searchListLastIndex;
					
					// refresh the contributions
					_pledgesModel.updatePledge();
				break;
				case '-99' :
					var eMsg:String = '';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_pledgesModel.refundError = new ErrorVO( 
						'There was a problem processing this refund:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
				break;	
			}
		}	
		
		private function onFault_upsertCheckRefund(event:Object):void
		{
			if(_pledgesModel.debug) Logger.info('upsertCheckRefund Fault', ObjectUtil.toString(event.fault));	
			
			_model.dataLoading = false;			
			_pledgesModel.refundError = new ErrorVO( 'There was a problem processing this record!<br><br>' + event.fault.faultString, 'errorBox', true );
		}	
		
		
		/**
		 * Delete a record
		 */		
		private function deleteRefund( event:PledgeEvent ):void
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteRefund', ObjectUtil.toString(event.recordVO));

			var handlers:IResponder = new mx.rpc.Responder(onResult_deleteRefund, onFault_deleteRefund);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

			_model.dataLoading = true;

			delegate.deleteRecord( event.recordVO );
		}
				
		private function onResult_deleteRefund( event:ResultEvent ):void 
		{
			if(_model.debug) Logger.info(_moduleName + ' deleteRefund Success', ObjectUtil.toString(event.result));

			_presentationModel.formProcessing = false;

			switch(event.result.state)
			{
				case '88' :
					_model.errorVO = new ErrorVO( 'That refund was deleted successfully!', 'successBox', true );

					// refresh the search list
					_presentationModel.lastQuery.dispatch();
					_presentationModel.searchListSelectedIndex = _presentationModel.searchListLastIndex;
					
					// refresh the contributions
					_pledgesModel.updatePledge();
						
					_model.dataLoading = false;
				break;
				case '-88' :
					var eMsg:String = '';
					for(var j:String in event.result.errors)
						eMsg += '- ' + event.result.errors[j] + '<br>';
						
					_model.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>' + eMsg, 
						'errorBox', 
						true 
					);
					_model.dataLoading = false;
				break;	
			}
		}
		
		private function onFault_deleteRefund( event:FaultEvent ):void
		{
			if(_model.debug) Logger.info('deleteRecord Fail', ObjectUtil.toString(event.fault));
			
			_model.dataLoading = false;			
			_model.errorVO = new ErrorVO( 'There was a problem processing this record!<br><br>' + event.fault.faultString, 'errorBox', true );
		}
	
	}
}