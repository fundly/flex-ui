package com.enilsson.elephantadmin.views.modules.dashboard.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	import com.enilsson.elephantadmin.events.modules.DashboardEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.models.Icons;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	import com.enilsson.elephantadmin.vo.SearchVO;
	import com.enilsson.utils.EDateUtil;
	
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.formatters.DateFormatter;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class DashboardModel
	{
		protected var mainModel : ModelLocator;

		public function DashboardModel( parentModel : ModelLocator = null )
		{
			mainModel = parentModel;
		}

		public function init():void
		{
			getLatestPledges();
			getActiveUsers();
			if(_selectedEvent)
				getEvent(_selectedEvent.id);
			else
				getSavedEvent();
		}

		public function refresh():void
		{
			getLatestPledges();
			getActiveUsers();
			if(_selectedEvent)
				getEvent(_selectedEvent.id);
			else
				getSavedEvent();
		}

		[Bindable] public var latestPledgesLoading:Boolean;
		[Bindable] 
		public function get latestPledges() : ArrayCollection {
			return _latestPledges; 
		}
		public function set latestPledges( value : ArrayCollection ) : void {
			_latestPledges = value;
		}
		private var _latestPledges : ArrayCollection;
		
		public function getLatestPledges() : void
		{
			if(latestPledgesLoading) return;
			latestPledgesLoading = true;
			
			// trigger event to populate pledges
			var getLatestPledgesEvent:DashboardEvent = new DashboardEvent(	DashboardEvent.GET_LATEST_PLEDGES,
																			new Responder(handleGetLatestPledgesResult, handleGetLatestPlegesFault)
																			);

			//eSQL syntax
			getLatestPledgesEvent.recordsVO = new RecordsVO(	'pledges<fname:lname:state:pledge_amount:created_on>(user_id<fname:lname:_fid>,event_id<source_code>)',
																null, 
																'pledges.id DESC', 
																0, 
																100, 
																null 
																);
			EAModelLocator(mainModel).dataLoading = true;
			getLatestPledgesEvent.dispatch();
		}
		
		private function handleGetLatestPledgesResult(event:Object):void 
		{
			if(EAModelLocator(mainModel).debug){ Logger.info('Dashboard getLatestPledges Success', ObjectUtil.toString(event.result)); }
			EAModelLocator(mainModel).dataLoading = false;

			var records:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result.pledges)
			{
				records.addItem(item);
			}
			latestPledges = records;
			latestPledgesLoading = false;
		}
		public function handleGetLatestPlegesFault(event:Object):void
		{
			if(EAModelLocator(mainModel).debug) Logger.info('Dashboard getLatestPledges Fail', ObjectUtil.toString(event));
			EAModelLocator(mainModel).dataLoading = false;
			latestPledgesLoading = false;
		}


		[Bindable] public var activeUsersLoading:Boolean;
		[Bindable] 
		public function get activeUsers() : ArrayCollection {
			return _activeUsers; 
		}
		public function set activeUsers( value : ArrayCollection ) : void {
			_activeUsers = value;
		}
		private var _activeUsers : ArrayCollection;
		

		public function getActiveUsers() : void
		{
			if(activeUsersLoading) return;
			activeUsersLoading = true;

			// trigger event to populate pledges
			var getActiveUsersEvent:DashboardEvent = new DashboardEvent(	DashboardEvent.GET_ACTIVE_USERS,
																			new Responder(handleGetActiveUsersResult, handleGetActiveUsersFault)
																			);

			EAModelLocator(mainModel).dataLoading = true;
			getActiveUsersEvent.dispatch();
		}
		
		private function handleGetActiveUsersResult(event:Object):void 
		{
			if(EAModelLocator(mainModel).debug){ Logger.info('Dashboard getActiveUsers Success', ObjectUtil.toString(event.result)); }
			EAModelLocator(mainModel).dataLoading = false;

			var users:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result)
			{
				users.addItem(item);
			}
			activeUsers = users;
			activeUsersLoading = false;
		}
		public function handleGetActiveUsersFault(event:Object):void
		{
			if(EAModelLocator(mainModel).debug) Logger.info('Dashboard getActiveUsers Fail', ObjectUtil.toString(event));
			EAModelLocator(mainModel).dataLoading = false;
			activeUsersLoading = false;
		}


		[Bindable] 
		public function get eventDescription() : String {
			return _eventDescription; 
		}
		public function set eventDescription( value : String ) : void {
			_eventDescription = value;
		}
		private var _eventDescription : String = "No event selected.";


		[Bindable] 
		public function get eventName() : String {
			return _eventName; 
		}
		public function set eventName( value : String ) : void {
			_eventName = value;
		}
		private var _eventName : String = "Event";
		
		
		public function get itemsPerPage() : Number {
			return EAModelLocator(mainModel).itemsPerPage;	
		}

 		public function eventSearch(event:Event):void 
		{
			var searchEventsEvent:DashboardEvent = new DashboardEvent(	DashboardEvent.SEARCH_EVENTS,
																			new Responder(handleSearchEventsResult, handleSearchEventsFault)
																			);
			//eSQL syntax
			searchEventsEvent.searchVO = new SearchVO(	'events',
														event.currentTarget.searchTerm + "*",
														null,
														0,
														200
														);
			EAModelLocator(mainModel).dataLoading = true;
			searchEventsEvent.dispatch();
		}
		private function handleSearchEventsResult(event:Object):void
		{
			if(EAModelLocator(mainModel).debug){ Logger.info('Dashboard SearchEvents Success', ObjectUtil.toString(event.result)); }
			EAModelLocator(mainModel).dataLoading = false;

			var records:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result[0].events)
			{
				records.addItem(item);
			}
			searchedEvents = records;
		}
		private function handleSearchEventsFault(event:Object):void
		{
			if(EAModelLocator(mainModel).debug) Logger.info('Dashboard SearchEvents Fail', ObjectUtil.toString(event));
			EAModelLocator(mainModel).dataLoading = false;
		}

		[Bindable] public var searchedEvents:ArrayCollection;

		[Bindable] 
		public function get selectedEvent() : Object {
			return _selectedEvent;
		}

		private function getSavedEvent():void
		{
			var soName:String = "instance"+EAModelLocator.getInstance().appInstanceID;
			var so:SharedObject = SharedObject.getLocal(soName, "/");
			if(so.data.lastViewedEventID)
				getEvent(so.data.lastViewedEventID);
			else
				_selectedEvent = new Object();
		}

		public function set selectedEvent(value:Object):void
		{
			_selectedEvent = value;
			eventName = _selectedEvent.source_code;
			var df:DateFormatter = new DateFormatter;
			df.formatString = "MM/DD/YYYY";
			eventDescription = _selectedEvent.name + " " + df.format(EDateUtil.timestampToLocalDate(_selectedEvent.date_time));
			getChartData(_selectedEvent.id);

			var soName:String = "instance"+EAModelLocator.getInstance().appInstanceID;
			var so:SharedObject = SharedObject.getLocal(soName, "/");
			so.data.lastViewedEventID = _selectedEvent.id;
			fundraising_goal = _selectedEvent.fundraising_goal;
		}
		private var _selectedEvent:Object;

		[Bindable] public var eventLoading:Boolean;
		public function getEvent(eventID:int):void
		{
			if(eventLoading) return;
			eventLoading = true;

			var getEventEvent:DashboardEvent = new DashboardEvent(	DashboardEvent.GET_EVENT,
																			new Responder(handleGetEventResult, handleGetEventFault)
																			);
			//eSQL syntax
			getEventEvent.recordVO = new RecordVO(	'events',
													eventID,
													null
												);
			EAModelLocator(mainModel).dataLoading = true;
			getEventEvent.dispatch();
		}

		private function handleGetEventResult(event:ResultEvent):void 
		{
			if(EAModelLocator(mainModel).debug){ Logger.info('Dashboard GetEvent Success', ObjectUtil.toString(event.result)); }
			EAModelLocator(mainModel).dataLoading = false;
			eventLoading = false;
			
			if(event.result.events[1])
				selectedEvent = event.result.events[1];
		}
		public function handleGetEventFault(event:FaultEvent):void
		{
			if(EAModelLocator(mainModel).debug) Logger.info('Dashboard GetEvent Fail', ObjectUtil.toString(event));
			EAModelLocator(mainModel).dataLoading = false;
			eventLoading = false;
		}

		/**
		 * Chart Model
		 **/

		// variables for the fundraising chart section
		[Bindable] public var fundraising:ArrayCollection = new ArrayCollection();
		[Bindable] public var chartData:ArrayCollection = new ArrayCollection();
		[Bindable] public var startMonth:int = -1;
		[Bindable] public var endMonth:int = 0;
		[Bindable] public var firstLabel:String = '';
		[Bindable] public var lastLabel:String = '';
		[Bindable] public var fundraising_goal:Number;
		[Bindable] public var goalLineErrorMsg:Boolean = false;
		[Bindable] public var goalLineProcessing:Boolean = false;

		public function get invitationIcon() : Class {
			return Icons.RSVP;
		}

		public function get pledgeIcon() : Class {
			return Icons.PLEDGE;
		}

		/**
		 * Get the fundraising statistics
		 */
		[Bindable] public var chartLoading:Boolean;
		public function getChartData(event_id:int):void
		{
			if(chartLoading) return;
			chartLoading = true;
			if(EAModelLocator(mainModel).debug){ Logger.info('Get Event Fundraising'); }
				// trigger event to populate pledges
				var getChartDataEvent:DashboardEvent = new DashboardEvent(	DashboardEvent.GET_EVENT_STATS,
																				new Responder(handleGetChartDataResult, handleGetChartDataFault)
																				);
				var where:Object = {'statement':'(1)','1':{ 
					'what' : 'events_statistics.event_id',
					'val' : event_id,
					'op' : '='
				}};

				//eSQL syntax
				getChartDataEvent.recordsVO = new RecordsVO(	'events_statistics<c:contrib_total:p:pledge_total:month:year>',
																where, 
																'events_statistics.year ASC events_statistics.month ASC'
																);
				EAModelLocator(mainModel).dataLoading = true;
				getChartDataEvent.dispatch();
			
			// show the data loading icon
			EAModelLocator(mainModel).dataLoading = true;
		}

		private function handleGetChartDataResult(data:Object):void 
		{
			if(EAModelLocator(mainModel).debug) Logger.info('My Fundraising Success', ObjectUtil.toString(data.result));
			
			// get the start month and end month
			var start:Date = new Date();
			var end:Date = new Date();
			var iter:int = 0;
			for(var t:String in data.result.events_statistics)
			{
				if(iter == 0)
				{
					start.setFullYear(
						data.result.events_statistics[t].year, 
						data.result.events_statistics[t].month - 1, 
						1
					);
				}
				if(iter == (data.result.events_statistics.length -1))
				{
					end.setFullYear(
						data.result.events_statistics[t].year, 
						data.result.events_statistics[t].month - 1, 
						1
					);
				}
				iter++;
			}
			
			// workout the number of months between start and end
			var periodArray:Array = new Array();
			while(start.getTime() <= end.getTime())
			{
				periodArray.push({ 'month' : start.getMonth() + 1, 'year' : start.getFullYear() });
				start.setFullYear(start.getFullYear(), start.getMonth() + 1, 1);
			}		
			
			// add all the items to the fundraising list
			var dp:ArrayCollection = new ArrayCollection();
			var item:Object;
			iter = 0;
			for(var i:String in periodArray)
			{
				item = new Object();		
				for(var k:String in data.result.events_statistics)
				{
					item = data.result.events_statistics[k];
					if(item.year == periodArray[i].year && item.month == periodArray[i].month) break;
				}
				
				var dpObj:Object = new Object();
				if(iter == 0){
					dpObj = {
						'label' : periodArray[i].month + '/' + periodArray[i].year.toString().substr(2,2),
						'month' : periodArray[i].month,
						'year' : periodArray[i].year,
						'Pledge' : ((item.pledge_total) ? parseInt(item.pledge_total) : 0),
						'Received' : ((item.contrib_total) ? parseInt(item.contrib_total) : 0),
						'Donors' : ((item.p) ? parseInt(item.p) : 0),
						'cPledge' : ((item.pledge_total) ? parseInt(item.pledge_total) : 0),
						'cReceived' : ((item.contrib_total) ? parseInt(item.contrib_total) : 0),
						'cDonors' : ((item.p) ? parseInt(item.p) : 0)
					}
				}
				else
				{
					if(item.length == 0)
					{
						dpObj = {
							'label' : periodArray[i].month + '/' + periodArray[i].year.toString().substr(2,2),
							'month' : periodArray[i].month,
							'year' : periodArray[i].year,
							'Pledge' : dp[iter-1].Pledge,
							'Received' : dp[iter-1].Received,
							'Donors' : dp[iter-1].Donors,
							'cPledge' : dp[iter-1].cPledge,
							'cReceived' : dp[iter-1].cReceived,
							'cDonors' : dp[iter-1].cDonors
						}
					}
					else
					{
						dpObj = {
							'label' : periodArray[i].month + '/' + periodArray[i].year.toString().substr(2,2),
							'month' : periodArray[i].month,
							'year' : periodArray[i].year,
							'Pledge' : parseInt(item.pledge_total),
							'Received' : parseInt(item.contrib_total),
							'Donors' : parseInt(item.p),
							'cPledge' : (parseInt(dp[iter-1].cPledge) + parseInt(item.pledge_total)),
							'cReceived' : (parseInt(dp[iter-1].cReceived) + parseInt(item.contrib_total)),
							'cDonors' : (parseInt(dp[iter-1].cDonors) + parseInt(item.p))
						}
					}
				}
				
				dp.addItem(dpObj);
				iter++;
			}
			
			if(dp.length == 1)
			{
				var bookend:Date = new Date();
				if(data.result.event_statistics)
				{
					bookend.setFullYear(
						data.result.events_statistics['1'].year, 
						data.result.events_statistics['1'].month - 2, 
						1
					);
				}
				var bookEndObj:Object = {
					'label' : String(bookend.getMonth() + 1) + '/' + String(bookend.getFullYear()).substr(2,2),
					'month' : (bookend.getMonth() + 1),
					'year' : bookend.getFullYear(),
					'Pledge' : 0,
					'Received' : 0,
					'Donors' : 0,
					'cPledge' : 0,
					'cReceived' : 0,
					'cDonors' : 0
				}
				
				dp.addItemAt(bookEndObj, 0);
			}
			
			// sort the array collection by year, month
			var sort:Sort = new Sort();
			sort.fields = [ new SortField('year', true, false, true), new SortField('month', true, false, true) ];
			dp.sort = sort;
			dp.refresh();
			
			// set the start and end months
			if(startMonth == -1)
			{
				if(EAModelLocator(mainModel).debug) Logger.info('Command StartMonth', startMonth);
				
				startMonth = dp.length - 4;
				endMonth = dp.length - 1;
			}
			
			// gate the chart data to the appropriate months
			if (EAModelLocator(mainModel).debug) { Logger.info('creating chartData'); }
			var newChartData:ArrayCollection = new ArrayCollection();
			for(var j:Number = 0; j<dp.length; j++)
			{
				if(j > startMonth - 1 && j < endMonth + 1)
				{ 
					newChartData.addItem(dp[j]);						
				}
			}
			
			chartData = newChartData;
			
			if (EAModelLocator(mainModel).debug) Logger.info('chartData created', ObjectUtil.toString(chartData));
			
			// set the label strings for the chart slider
			firstLabel = dp[0].label;
			lastLabel = dp[dp.length-1].label;		
			
			// add the array collection to the model for binding
			fundraising = dp;
			
			// hide the data loading indicator
			EAModelLocator(mainModel).dataLoading = false;
			chartLoading = false;
		}	

		private function handleGetChartDataFault(data:Object):void
		{
			if(EAModelLocator(mainModel).debug) Logger.info('My Fundraising Fault', ObjectUtil.toString(data.fault));	
			chartLoading = false;
			EAModelLocator(mainModel).dataLoading = false;			
		}		
	}
}