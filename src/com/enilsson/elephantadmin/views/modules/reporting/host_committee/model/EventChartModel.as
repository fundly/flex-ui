package com.enilsson.elephantadmin.views.modules.reporting.host_committee.model
{
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class EventChartModel
	{
		[Bindable] public var fundraising:ArrayCollection = new ArrayCollection();
		[Bindable] public var chartData:ArrayCollection = new ArrayCollection();
		[Bindable] public var startMonth:int = -1;
		[Bindable] public var endMonth:int = 0;
		[Bindable] public var firstLabel:String = '';
		[Bindable] public var lastLabel:String = '';
		[Bindable] public var newGoalLine:int;
		[Bindable] public var goalLineErrorMsg:Boolean = false;
		[Bindable] public var goalLineProcessing:Boolean = false;
		private var gatewayURL:String;

		public function EventChartModel(url:String):void
		{
			gatewayURL = url;
		}

		/**
		 * Get the fundraising statistics
		 */
		public function getChartData(event_id:int):void
		{
			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'events_statistics.event_id',
				'val' : event_id,
				'op' : '='
			}};

			//eSQL syntax
			var r:RecordsVO = new RecordsVO(	
				'events_statistics<c:contrib_total:p:pledge_total:month:year>',
				where, 
				'events_statistics.year ASC events_statistics.month ASC'
			);
			
 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'struktor.select';
			amfService.addEventListener(ResultEvent.RESULT, handleGetChartDataResult);
			amfService.addEventListener(FaultEvent.FAULT, handleGetChartDataFault); 
			amfService['record_tree'].send.apply(null, [r.table, r.where, r.sort, r.iFrom, r.iCount, r.options]);	
		}

		private function handleGetChartDataResult(data:Object):void 
		{		
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
				
				startMonth = dp.length - 4;
				endMonth = dp.length - 1;
			}
			
			// gate the chart data to the appropriate months
			var newChartData:ArrayCollection = new ArrayCollection();
			for(var j:Number = 0; j<dp.length; j++)
			{
				if(j > startMonth - 1 && j < endMonth + 1)
				{ 
					newChartData.addItem(dp[j]);						
				}
			}
			
			chartData = newChartData;
			
			
			// set the label strings for the chart slider
			firstLabel = dp[0].label;
			lastLabel = dp[dp.length-1].label;		
			
			// add the array collection to the model for binding
			fundraising = dp;
			
			// hide the data loading indicator
		}	

		private function handleGetChartDataFault(data:Object):void
		{
			
		}		
	}
}