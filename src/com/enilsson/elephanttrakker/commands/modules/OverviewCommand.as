package com.enilsson.elephanttrakker.commands.modules
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.business.RecordDelegate;
	import com.enilsson.elephanttrakker.business.RecordsDelegate;
	import com.enilsson.elephanttrakker.events.modules.overview.*;
	import com.enilsson.elephanttrakker.events.session.UpdateSessionEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.vo.RecordVO;
	import com.enilsson.elephanttrakker.vo.RecordsVO;
	import com.enilsson.utils.EDateUtil;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class OverviewCommand extends SequenceCommand implements ICommand, IResponder
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function OverviewCommand()
		{
		}

		override public function execute(event:CairngormEvent):void
		{
			if(_model.debug){ Logger.info('Overview Command', ObjectUtil.toString(event.type)); }
			
			switch(event.type)
			{
				case AnnouncementsEvent.EVENT_ANNOUNCEMENTS :
					getAnnouncements(event as AnnouncementsEvent);
				break;
				case MyFundraisingEvent.EVENT_MY_FUNDRAISING :
					getFundraising(event as MyFundraisingEvent);
				break;
				case UpdateGoalLineEvent.EVENT_UPDATE_GOALLINE :
					updateGoalLine(event as UpdateGoalLineEvent);
				break;
			}
		}
		
		/**
		 * Stubs required for IResponder interface; need as Delegate constructor argument
		 */
		public function fault(info:Object):void { Logger.info(info.toString()); }
		public function result(data:Object):void { /* no longer used */ }
		
		
		/**
		 * Get the announcements
		 */
		private function getAnnouncements(event:AnnouncementsEvent):void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getAnnouncements, onFault_getAnnouncements);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;

			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'news.publish',
				'val' : 1,
				'op' : '='
			}};
			
			delegate.getRecords( new RecordsVO( 'news<title:publish_date:publish:description>', where, 'news.publish_date DESC' ) );
		}

		private function onResults_getAnnouncements(data:Object):void 
		{
			if(_model.debug){ Logger.info('Announcements Success', ObjectUtil.toString(data.result)); }
			
			// add all the items to the announcements list
			var dp:ArrayCollection = new ArrayCollection();
			for(var i:String in data.result.news)
			{
				var item:Object = data.result.news[i];
				//item.description = eNilssonUtils.cleanRteHTML(item.description);
				var df:DateFormatter = new DateFormatter();
				df.formatString = "MM/DD/YYYY";
				item.date = (df.format( EDateUtil.dateFromTimestamp(item.publish_date) ) );
				
				dp.addItem(data.result.news[i]);
			}
			_model.overview.announcements = dp;
			if (dp.length > 0) {
				_model.overview.selectedAnnouncement = dp[0];
			}
			
			if(_model.debug) Logger.info('Announcements Cleaned', ObjectUtil.toString(_model.overview.selectedAnnouncement));

			this.nextEvent = new MyFundraisingEvent();
			this.executeNextCommand();
			this.nextEvent = null;
			
			_model.overview.isProcessing = false;			
						
			_model.dataLoading = false;
		}	

		private function onFault_getAnnouncements(data:Object):void
		{
			if(_model.debug){ Logger.info('Announcements Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.dataLoading = false;			

			_model.overview.isProcessing = false;			
		}
		

		/**
		 * Update the goalline
		 */
		private function updateGoalLine(event:UpdateGoalLineEvent):void
		{			
			var handlers:IResponder = new mx.rpc.Responder(onResults_updateGoalLine, onFault_updateGoalLine);
			var delegate:RecordDelegate = new RecordDelegate(handlers);
			
			// show the data loading icon
			_model.overview.goalLineProcessing = true;
			
			var params:Object = { 'user_id' : _model.session.user_id, '_fundraising_goal' : parseInt(event.newGoalLine) };
			delegate.upsertRecord( new RecordVO('tr_users', 0, null, params) ); 
		}

		private function onResults_updateGoalLine(data:Object):void 
		{
			if(_model.debug){ Logger.info('updateGoalLine Success', ObjectUtil.toString(data.result)); }
			
			this.nextEvent = new UpdateSessionEvent();
			this.executeNextCommand();
			this.nextEvent = null;
			
			_model.overview.goalLineProcessing = false;
			_model.overview.goalLineErrorMsg = true;
		}	

		private function onFault_updateGoalLine(data:Object):void
		{
			if(_model.debug){ Logger.info('updateGoalLine Fault', ObjectUtil.toString(data.fault)); }	
			
			_model.overview.goalLineProcessing = false;			
		}		
		
		
		/**
		 * Get the fundraising statistics
		 */
		private function getFundraising(event:MyFundraisingEvent):void
		{
			if(_model.debug){ Logger.info('Get My Fundraising'); }
			
			var handlers:IResponder = new mx.rpc.Responder(onResults_getFundraising, onFault_getAnnouncements);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			// show the data loading icon
			_model.dataLoading = true;

			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'statistics.created_by_id',
				'val' : _model.session.user_id,
				'op' : '='
			}};
			
			delegate.getRecords( 
				new RecordsVO( 'statistics<c:contrib_total:p:pledge_total:month:year>', where, 'statistics.year ASC statistics.month ASC' ) 
			);
		}

		private function onResults_getFundraising(data:Object):void 
		{
			if(_model.debug) Logger.info('My Fundraising Success', ObjectUtil.toString(data.result));
			
			// get the start month and end month
			var start:Date = new Date();
			var end:Date = new Date();
			var iter:int = 0;
			for(var t:String in data.result.statistics)
			{
				if(iter == 0)
				{
					start.setFullYear(
						data.result.statistics[t].year, 
						data.result.statistics[t].month - 1, 
						1
					);
				}
				if(iter == (data.result.statistics.length -1))
				{
					end.setFullYear(
						data.result.statistics[t].year, 
						data.result.statistics[t].month - 1, 
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
				for(var k:String in data.result.statistics)
				{
					item = data.result.statistics[k];
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
			
			// add dummy bookend data to start the charting, will be zero for everything
			var bookend:Date = new Date();
			bookend.setFullYear(
				data.result.statistics['1'].year, 
				data.result.statistics['1'].month - 2, 
				1
			);
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
			
			// sort the array collection by year, month
			var sort:Sort = new Sort();
			sort.fields = [ new SortField('year', true, false, true), new SortField('month', true, false, true) ];
			dp.sort = sort;
			dp.refresh();
			
			// set the start and end months
			if(_model.overview.startMonth == -1)
			{
				if(_model.debug) Logger.info('Command StartMonth', _model.overview.startMonth);
				
				_model.overview.startMonth = dp.length - 4;
				_model.overview.endMonth = dp.length - 1;
			}
			
			// gate the chart data to the appropriate months
			if (_model.debug) { Logger.info('creating chartData'); }
			var chartData:ArrayCollection = new ArrayCollection();
			for(var j:Number = 0; j<dp.length; j++)
			{
				if(j > _model.overview.startMonth - 1 && j < _model.overview.endMonth + 1)
				{ 
					chartData.addItem(dp[j]);						
				}
			}
			
			_model.overview.chartData = chartData;
			
			if (_model.debug) Logger.info('chartData created', ObjectUtil.toString(_model.overview.chartData));
			
			// set the label strings for the chart slider
			_model.overview.firstLabel = dp[0].label;
			_model.overview.lastLabel = dp[dp.length-1].label;		
			
			// add the array collection to the model for binding
			_model.overview.fundraising = dp;
			
			// show the chart
			_model.overview.showChart = true;
			
			// hide the data loading indicator
			_model.dataLoading = false;
		}	

		private function onFault_getFundraising(data:Object):void
		{
			if(_model.debug) Logger.info('My Fundraising Fault', ObjectUtil.toString(data.fault));	
			
			_model.dataLoading = false;			
		}		
	}
}