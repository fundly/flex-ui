package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.*;
	import com.enilsson.elephanttrakker.events.modules.my_history.*;
	import com.enilsson.elephanttrakker.events.session.SessionEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.*;
	import com.enilsson.utils.eNilssonUtils;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class MyHistoryCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MyHistoryCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('MyHistory Command', ObjectUtil.toString(event.type)); }	
			
			switch(event.type)
			{
				case MyHistoryGetPledgesEvent.EVENT_MYHISTORY_GET_PLEDGES :
					_model.my_history.lastQuery = event;	
					getPledges(event as MyHistoryGetPledgesEvent);
				break;	
				case MyHistoryGetContribsEvent.EVENT_MYHISTORY_GET_CONTRIBS :
					getContribs(event as MyHistoryGetContribsEvent);
				break;
				case MyHistoryGetContribsEvent.EVENT_MYHISTORY_GET_CHECK_CONTRIBS :
					getCheckContribs(event as MyHistoryGetContribsEvent);
				break;
				case MyHistoryGetSavedCallsEvent.EVENT_MYHISTORY_GET_SAVEDCALLS :
					_model.my_history.lastSavedQuery = event;
					getSavedCalls(event as MyHistoryGetSavedCallsEvent);
				break;
				case MyHistorySearchEvent.EVENT_SEARCH_MYHISTORY :
					_model.my_history.lastQuery = event;
					searchTable(event as MyHistorySearchEvent);
				break;			
				case MyHistoryEvent.EVENT_STATS :
					getStats(event as MyHistoryEvent);
				break;
				case MyHistoryEvent.EVENT_DOWNLINE :
					getDownline(event as MyHistoryEvent);
				break;
				case MyHistoryEvent.EVENT_CHART :
					getChart(event as MyHistoryEvent);
				break;
				case MyHistoryEvent.EVENT_EXPORT :
					exportTables(event as MyHistoryEvent);
				break;
				case MyHistoryEvent.GET_TOPDONORS :
					getTopDonors(event as MyHistoryEvent);
				break;
				case MyHistoryEvent.DELETE_PLEDGE :
					deletePledge(event as MyHistoryEvent);
				break;				
				case MyHistoryEvent.DELETE_SAVED_PLEDGE :
					deleteSavedPledge(event as MyHistoryEvent);
				break;								
			}	
			
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }

		/**
		 * Get the users pledge data
		 */
		private function getPledges(event:MyHistoryGetPledgesEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getPledges, onFault_getPledges);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;
			
			var sort:String = event.sort == '' ? 'pledges.pledge_date DESC pledges.created_on DESC' : event.sort;

			var where:Object = null;
			if(event.where == null)
			{
				where = {'statement':'(1)','1':{ 
					'what' : 'pledges.created_by_id',
					'val' : _model.session.user_id,
					'op' : '='
				}};
			}
			else
				where = event.where;
			
			var r:RecordsVO = new RecordsVO( 'pledges(event_id<source_code>)', where, sort, event.iFrom, event.iCount, event.paginate );
			
			if(_model.debug) Logger.info('MyHistory Pledges', ObjectUtil.toString(r));
			
			delegate.getRecords( r );
		}

		private function onResults_getPledges(data:Object):void 
		{
			if(_model.debug) Logger.info('getPledges Success', ObjectUtil.toString(data.result));
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result.pledges)
			{
				item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;
				item['fullName'] = item.lname + ', ' + item.fname;
				item['sourceCode'] = item.event_id.source_code;
				
				dp.addItem(item);				
			}
			// assign the altered array collection to the model for binding
			_model.my_history.pledges = dp;
			// save the number of contacts
			if(data.result.total_rows)
				_model.my_history.numPledges = parseInt(data.result.total_rows);
			
			_model.dataLoading = false;
			
			_model.my_history.isSorting = false;
		}	

		private function onFault_getPledges(data:Object):void
		{
			if(_model.debug) Logger.info('getPledges Fault');	
			
			_model.dataLoading = false;			
		}		


		/**
		 * Search data in a specific table
		 */
		private function searchTable(event:MyHistorySearchEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_searchTable, onFault_searchTable);
			var delegate:SearchDelegate = new SearchDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true
			
			if( event.search )
				delegate.search( event.search );
		}

		private function onResults_searchTable(data:Object):void 
		{
			if(_model.debug){ Logger.info('searchTable Success', ObjectUtil.toString(data.result)); }
			
			var dataObj:Object = data.result[0];
			var table:String = data.result[0].table_name;
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in dataObj[table])
			{
				item['fullAddress'] = item.address1 + ', ' + item.city + ' ' + item.state;
				item['fullName'] = item.lname + ', ' + item.fname;
				
				dp.addItem(item);				
			}
			// assign the altered array collection to the model for binding
			_model.my_history[table] = dp;
			// save the number of records
			switch(table)
			{
				case 'pledges' :
					_model.my_history.numPledges = parseInt(dataObj.found_rows);
				break;
				case 'transactions' :
					_model.my_history.numContribs = parseInt(dataObj.found_rows);
				break;
				case 'checks' :
					_model.my_history.numCheckContribs = parseInt(dataObj.found_rows);
				break;
				case 'user_storage' :
					_model.my_history.numSavedCalls = parseInt(dataObj.found_rows);
				break;				
			}
			
			_model.dataLoading = false;
		}	

		private function onFault_searchTable(data:Object):void
		{
			if(_model.debug) Logger.info('searchTable Fault');	
			
			_model.dataLoading = false;			
		}		


		/**
		 * Get the users contribution data
		 */
		private function getContribs(event:MyHistoryGetContribsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getContribs, onFault_getContribs);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;
			
			var sort:String = event.sort == '' ? 'transactions.created_on DESC' : event.sort;

			var where:Object= {'statement':'(1)','1':{ 
				'what' : 'transactions.created_by_id',
				'val' : _model.session.user_id,
				'op' : '='
			}};		
			
			delegate.getRecords( 
				new RecordsVO( 'transactions', where, sort, event.iFrom, event.iCount, event.paginate ) 
			);
		}

		private function onResults_getContribs(data:Object):void 
		{
			if(_model.debug){ Logger.info('getContribs Success', ObjectUtil.toString(data.result)); }
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result.transactions)
			{
				dp.addItem(item);				
			}
			// assign the altered array collection to the model for binding
			_model.my_history.transactions = dp;
			// save the number of contacts
			if(data.result.total_rows)
				_model.my_history.numContribs = parseInt(data.result.total_rows);
			
			_model.dataLoading = false;
			_model.my_history.isSorting = false;
		}	

		private function onFault_getContribs(data:Object):void
		{
			if(_model.debug) Logger.info('getContribs Fault');	
			
			_model.dataLoading = false;			
		}		


		/**
		 * Get the users contribution data
		 */
		private function getCheckContribs(event:MyHistoryGetContribsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getCheckContribs, onFault_getCheckContribs);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;
			
			var sort:String = event.sort == '' ? 'checks.created_on DESC' : event.sort;

			var where:Object= {'statement':'(1)','1':{ 
				'what' : 'checks.created_by_id',
				'val' : _model.session.user_id,
				'op' : '='
			}};		
			
			delegate.getRecords( 
				new RecordsVO( 'checks', where, sort, event.iFrom, event.iCount, event.paginate ) 
			);
		}

		private function onResults_getCheckContribs(data:Object):void 
		{
			if(_model.debug){ Logger.info('getCheckContribs Success', ObjectUtil.toString(data.result)); }
			
			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result.checks)	
			{
				dp.addItem(item);				
			}
			// assign the altered array collection to the model for binding
			_model.my_history.checks = dp;
			// save the number of contacts
			if(data.result.total_rows)
				_model.my_history.numCheckContribs = parseInt(data.result.total_rows);
			
			_model.dataLoading = false;
			_model.my_history.isSorting = false;
		}	

		private function onFault_getCheckContribs(data:Object):void
		{
			if(_model.debug) Logger.info('getCheckContribs Fault');	
			
			_model.dataLoading = false;			
		}		


		/**
		 * Get the statistics
		 */
		private function getStats(event:MyHistoryEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getStats, onFault_getStats);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;
			
			var sort:String = 'statistics.year ASC statistics.month ASC';

			var where:Object= {'statement':'(1)','1':{ 
				'what' : 'statistics.created_by_id',
				'val' : _model.session.user_id,
				'op' : '='
			}};		
			
			delegate.getRecords( 
				new RecordsVO( 'statistics<c:contrib_total:p:pledge_total:month:year>', where, sort ) 
			);
		}

		private function onResults_getStats(data:Object):void 
		{
			if(_model.debug) Logger.info('My Quick Stats Success', ObjectUtil.toString(data.result));
			
			var numDonors:int = 0;
			var totalPledged:int = 0;
			var totalContribs:int = 0;
			var avPerDonor:int = 0;
			
			for(var i:String in data.result.statistics)
			{
				var item:Object = data.result.statistics[i];

				numDonors += parseInt(item.p);
				totalContribs += parseInt(item.contrib_total);
				totalPledged += parseInt(item.pledge_total);
			}

			_model.my_history.numDonors = numDonors;
			_model.my_history.totalPledged = totalPledged;
			_model.my_history.totalContribs = totalContribs;
			_model.my_history.avPerDonor = Math.round(totalPledged/numDonors);

			
			// hide the data loading indicator
			_model.dataLoading = false;
		}	

		private function onFault_getStats(data:Object):void
		{
			if(_model.debug) Logger.info('My Quick Stats Fault');	
			
			_model.dataLoading = false;			
		}
		
		/**
		 * Get the downline
		 */
		private function getDownline(event:MyHistoryEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getDownline, onFault_getDownline);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			_model.dataLoading = true;
			
			delegate.selectRecord( new RecordVO('downline_stats',_model.session.user_id) );
		}

		private function onResults_getDownline(data:Object):void 
		{
			if(_model.debug) Logger.info('My Downline Success', ObjectUtil.toString(data.result));

			_model.my_history.downline = data.result['downline_stats'][1].pledge;

			this.nextEvent = new MyHistoryEvent( MyHistoryEvent.GET_TOPDONORS );
			this.executeNextCommand();
			this.nextEvent = null;
		}	

		private function onFault_getDownline(data:Object):void
		{
			if(_model.debug) Logger.info('My Downline Fault');
			
			_model.dataLoading = false;			
		}
		

		/**
		 * Get the chart 
		 */
		private function getChart(event:MyHistoryEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getChart, onFault_getChart);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			_model.dataLoading = true;
			
			delegate.countRecords( new CountingVO( 'pledges','state','pledge_amount' ) );
		}

		private function onResults_getChart(data:Object):void 
		{
			if(_model.debug){ Logger.info('Chart load Successfully', ObjectUtil.toString(data.result)); }
			
			var chart:ArrayCollection = new ArrayCollection();
			for each(var item:Object in data.result)
				chart.addItem({'state':item.group,'dollars':item.sum.pledge_amount,'donors':item.frequency});			
		
  			var dataSortField:SortField = new SortField();
            dataSortField.name = "state";
            dataSortField.reverse();            

            // Create the Sort object and add the SortField object created earlier to the array of fields to sort on.
            var mysort:Sort = new Sort();
            mysort.fields = [dataSortField];

            // Set the ArrayCollection object's sort property to our custom sort, and refresh the ArrayCollection.
            chart.sort = mysort;
            chart.refresh();

			_model.my_history.quickstats_chart = chart;
			
			// hide the data loading indicator
			_model.dataLoading = false;
		}	

		private function onFault_getChart(data:Object):void
		{
			if(_model.debug) Logger.info('Chart load Fault');	
			
			_model.dataLoading = false;			
		}		



		/**
		 * Get the users saved pledges
		 */
		private function getSavedCalls(event:MyHistoryGetSavedCallsEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getSavedCalls, onFault_getSavedCalls);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;
			
			var sort:String = event.sort == '' ? 'user_storage.modified_on DESC' : event.sort;

			var where:Object = {
				'statement' : '(1 AND 2)',
				'1' : { 
					'what' : 'user_storage.table',
					'val' : 'pledges',
					'op' : '='
				},
				'2':{ 
					'what' : 'user_storage.created_by_id',
					'val' : _model.session.user_id,
					'op' : '='
				}
			};
			
			delegate.getRecords( new RecordsVO( 'user_storage', where, sort ) );
		}

		private function onResults_getSavedCalls(data:Object):void 
		{
			if(_model.debug) Logger.info('getSavedCalls Success', ObjectUtil.toString(data.result));
			
			// add some convenience items to the array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var saved:Object in data.result.user_storage)	
			{	
				var saved_call:Object = eNilssonUtils.unserialize(saved.data);
				
				if(saved_call == null || !saved_call.hasOwnProperty('vo')) continue;
				
				saved['data'] 			= saved_call;				
				saved['fname'] 			= saved_call.vo.pledge.fname;
				saved['lname'] 			= saved_call.vo.pledge.lname;
				saved['address1'] 		= saved_call.vo.pledge.address1;
				saved['city'] 			= saved_call.vo.pledge.city;
				saved['state'] 			= saved_call.vo.pledge.state;
				saved['pledge_amount'] 	= saved_call.vo.pledge.pledge_amount;				
				
				dp.addItem(saved);				
			}
			
			// assign the altered array collection to the model for binding
			_model.my_history.user_storage = dp;

			if(data.result.total_rows)
				_model.my_history.numSavedCalls = parseInt(data.result.total_rows);
			
			_model.dataLoading = false;
			_model.my_history.isSorting = false;
		}	

		private function onFault_getSavedCalls(data:Object):void
		{
			if(_model.debug) Logger.info('getSavedCalls Fault');	
			
			_model.dataLoading = false;			
		}	
		

		/**
		 * Export user data
		 */
		private function exportTables(event:MyHistoryEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_exportTables, onFault_exportTables);
			
			_model.dataLoading = true
			_model.my_history.exportTable = event.obj.table_name;

			if ( event.obj.table_name == 'contacts' )
			{
				var delg:PluginsDelegate = new PluginsDelegate(handlers);
				delg.export_contacts();				
			}
			else
			{
				var delegate:RecordDelegate = new RecordDelegate(handlers);
				var where:Object= {'statement':'(1)','1':{ 
					'what' : event.obj.table_name + '.created_by_id',
					'val' : _model.session.user_id,
					'op' : '='
				}};		
				delegate.exportRecords( event.obj.table_name, where );
			}
		}

		private function onResults_exportTables(data:Object):void 
		{
			if(_model.debug) Logger.info('exportTables Success', ObjectUtil.toString(data.result));
			
			var d:Date = new Date();
			var df:DateFormatter = new DateFormatter();
			df.formatString = 'MMDDYYYY';
			
			var fileName:String = 'my-blueswarm-' + _model.my_history.exportTable + '-' + df.format(d);
			
			navigateToURL(new URLRequest(_model.gatewayBaseURL + '/export.php?id='+ data.result + '&file_name=' + fileName ), '_parent') 
			
			_model.dataLoading = false;
		}	

		private function onFault_exportTables(data:Object):void
		{
			if(_model.debug) Logger.info('exportTables Fault');
			
			_model.dataLoading = false;			
		}	

		
		/**
		 * Get a list of the topdonors for the user
		 */
		private function getTopDonors(event:MyHistoryEvent):void
		{
			if (_model.debug) Logger.info('Getting Top Donors');
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getTopDonors, onFault_getTopDonors);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;

			var where:Object = {
				'statement':'(1 AND 2 AND 3)',
				'1':{ 
					'what' : 'pledges.pledge_amount',
					'val' : 0,
					'op' : '>'
				},
				'2':{ 
					'what' : 'pledges.contrib_total',
					'val' : 0,
					'op' : '>'
				},
				'3' : {
					'what' : 'pledges.created_by_id',
					'val' : _model.session.user_id,
					'op' : '='
				}
			};


			delegate.getRecords( new RecordsVO('pledges<fname:lname:state:pledge_amount:contrib_total>', where, 'pledges.pledge_amount DESC', 0, 50) );
		}

		private function onResults_getTopDonors(data:Object):void 
		{
			if(_model.debug) Logger.info('getTopDonors Success', ObjectUtil.toString(data.result)); 
			
			_model.dataLoading = false;

			// add some convenience items to the contacts array collection
			var dp:ArrayCollection = new ArrayCollection()
			for each( var item:Object in data.result.pledges )	
			{
				item['fullName'] = item.lname + ', ' + item.fname;
				
				dp.addItem(item);				
			}
			
			_model.my_history.topDonors = dp;
		}	

		private function onFault_getTopDonors(data:Object):void
		{
			if(_model.debug) Logger.info('getTopDonors Fault');
			
			_model.dataLoading = false;			
		}	


		/**
		 * Delete a pledge
		 */
		private function deletePledge(event:MyHistoryEvent):void
		{
			if (_model.debug) Logger.info('Delete a Pledge');
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_deletePledge, onFault_deletePledge);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

 			// show the data loading icon
			_model.dataLoading = true;

			delegate.deleteRecord( new RecordVO('pledges', event.obj.pledge_id ) );
		}

		private function onResults_deletePledge(event:Object):void 
		{
			if(_model.debug) Logger.info('deletePledge Success', ObjectUtil.toString(event.result)); 
			
			_model.dataLoading = false;
			
			switch (event.result.state)
			{
				case '-87' :
				case '-88' :
					var eMsg:String = 'There was a problem deleting this pledge:<br><br>';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.my_history.errorVO = new ErrorVO( eMsg, 'errorBox', true );
				break;
				case '88' :
					_model.my_history.errorVO = new ErrorVO( 'The pledge was successfully deleted', 'successBox', true );
					
					this.nextEvent = _model.my_history.lastQuery;
					this.executeNextCommand();
					this.nextEvent = null;
					
					// update quickstats statistics
					new SessionEvent(SessionEvent.GET_SESSION_INFO).dispatch();
				break;				
			}
		}	

		private function onFault_deletePledge(event:Object):void
		{
			if(_model.debug) Logger.info('deletePledge Fault');
			
			_model.dataLoading = false;			
		}	
		

		/**
		 * Delete a savedpledge
		 */
		private function deleteSavedPledge(event:MyHistoryEvent):void
		{
			if(_model.debug) Logger.info('Delete a Saved Pledge');
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_deleteSavedPledge, onFault_deleteSavedPledge);
			var delegate:RecordDelegate = new RecordDelegate(handlers);

 			// show the data loading icon
			_model.dataLoading = true;

			delegate.deleteRecord( new RecordVO('user_storage', event.obj.id ) );
		}

		private function onResults_deleteSavedPledge(event:Object):void 
		{
			if(_model.debug) Logger.info('deleteSavedPledge Success', ObjectUtil.toString(event.result)); 
			
			_model.dataLoading = false;
			
			switch (event.result.state)
			{
				case '-88' :
					var eMsg:String = 'There was a problem deleting this saved pledge:<br><br>';
					for(var i:String in event.result.errors)
						eMsg += '- ' + event.result.errors[i] + '<br>';
						
					_model.my_history.errorVO = new ErrorVO( eMsg, 'errorBox', true );
				break;
				case '88' :
					_model.my_history.errorVO = new ErrorVO( 'The saved pledge was successfully deleted', 'successBox', true );
					
					this.nextEvent = _model.my_history.lastSavedQuery;
					this.executeNextCommand();
					this.nextEvent = null;
					
					// trigger a reset of the pledge form
					//_model.call_logging.reset(); 
				break;				
			}
		}	

		private function onFault_deleteSavedPledge(event:Object):void
		{
			if(_model.debug) Logger.info('deleteSavedPledge Fault');
			
			_model.dataLoading = false;			
		}			

	}
}