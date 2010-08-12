package com.enilsson.elephantadmin.views.modules.reporting.dailyincome.model
{
	import com.enilsson.elephantadmin.events.main.SidEvent;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportModuleModel;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportResultVO;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.utils.EDateUtil;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.charts.events.ChartItemEvent;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.Application;
	import mx.events.DataGridEvent;
	import mx.events.ListEvent;
	import mx.formatters.DateFormatter;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	[Bindable]
	public class DailyIncomeModel extends ReportModuleModel
	{
		public var regionFilter:ArrayCollection = new ArrayCollection([
			{'label':'All','data':'0'}
		]);
		public var chartFilter:ArrayCollection = new ArrayCollection([
			{'label':'Total Income','data':'0'},
			{'label':'Daily Income','data':'1'},
			{'label':'Cash on Hand','data':'2'}
		]);
		public var selectedChartIndex:int = 0;
		// default start date
		public var startDate:Date = EDateUtil.today();
		// default end date is end of today
		public var endDate:Date = EDateUtil.today();

		public function set summaryDate(value:Date):void
		{
			_summaryDate = value;
			generateSummary();
		}
		private var _summaryDate:Date = new Date(new Date().getFullYear(),new Date().getMonth(),new Date().getDate());
		public function get summaryDate():Date
		{
			return _summaryDate;
		}
		public var summaryGroup:int;

		public var sortArray:Array = ['downline_pledge DESC'];
		public var exportHeaders:Array = [];
		public var exportFields:Array = [];
		public var exportTitle:String = "";

		public var recordsHtmlText:String;
		public var totalGraphData:ArrayCollection;
		public var incomeGraphData:ArrayCollection;
		public var summaryRecord:ArrayCollection = new ArrayCollection();
		
		public function DailyIncomeModel():void
		{
			// default start date is 1 week from today
			startDate.setDate( startDate.getDate() - 7 );
		}

		override public function init():void
		{
			super.init();
			for each(var item:Object in userGroups)
			{
				regionFilter.addItem(item);
			}
			generateGraph();
			generateSummary();
		}

		public function regionChangeHandler(event:ListEvent):void
		{
			summaryGroup = event.currentTarget.selectedItem.value;
		}

		public function generateGraph():void
		{
			dataLoading = true;
			
			EDateUtil.setEndOfDay(endDate);
			
			var vo:ReportVO = new ReportVO();

			vo.startTime = EDateUtil.localDateToTimestamp(startDate);
			vo.endTime = EDateUtil.localDateToTimestamp(endDate);
			vo.groupID = group;

			if(exporting)
			{
				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				exportTitle = 'Fundraisers - ' + regionFilter.getItemAt(group).label;
				vo.exportTitle = exportTitle;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
				vo.exportTimeOffset = timezoneOffset;
			}

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.common.reporting.daily_income';
			amfService['get_graph'].send.apply(null, [vo]);	
			amfService.addEventListener(ResultEvent.RESULT, generateGraphResult);
			amfService.addEventListener(FaultEvent.FAULT, generateFault); 
		}

		public function addExpenditure(amount:Number):void
		{
			var date:int = EDateUtil.localDateToTimestamp(summaryDate);
			
 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.common.reporting.daily_income';
			amfService['add_expenditure'].send.apply(null, [date, amount]);	
			amfService.addEventListener(ResultEvent.RESULT, addExpenditureResult);
			amfService.addEventListener(FaultEvent.FAULT, generateFault); 
		}

		public function addExpenditureResult(event:ResultEvent):void
		{
			generateSummary();
			generateGraph();
		}

		public function generateSummary():void
		{
			dataLoading = true;
			
			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");

			vo.sortBy = sortBy;
			vo.startTime = EDateUtil.localDateToTimestamp(summaryDate);
			vo.groupID = summaryGroup;

			if(exporting)
			{
				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				exportTitle = 'Fundraisers - ' + regionFilter.getItemAt(group).label;
				vo.exportTitle = exportTitle;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
				vo.exportTimeOffset = timezoneOffset;
			}

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.common.reporting.daily_income';
			amfService['get_summary'].send.apply(null, [vo]);	
			amfService.addEventListener(ResultEvent.RESULT, generateSummaryResult);
			amfService.addEventListener(FaultEvent.FAULT, generateFault); 
		}

		private function generateGraphResult(event:ResultEvent):void
		{
			dataLoading = false;	

			if(event.result is ReportResultVO)
			{
				var vo:ReportResultVO = event.result as ReportResultVO;

				totalGraphData = new ArrayCollection();
				var total:Object;

				var totalBefore:Object = vo.list[0];

				totalGraphData.addItem(totalBefore);
				for(var i:int=1; i<vo.list.length; i++)
				{
					total = {};
					total.date = vo.list[i].date;
					
					var today:Number = vo.list[i].pledge;
					var untilToday:Number = totalGraphData[i-1].pledge;
					total.pledge = today + untilToday;

					today = vo.list[i].check;
					untilToday = totalGraphData[i-1].check;
					total.check = today + untilToday;

					today = vo.list[i].credit;
					untilToday = totalGraphData[i-1].credit;
					total.credit = today + untilToday;

					today = vo.list[i].paypal;
					untilToday = totalGraphData[i-1].paypal;
					total.paypal = today + untilToday;
					
					total.totalContrib = Number(total.check) + Number(total.credit) + Number(total.paypal);
					total.expenditure = vo.list[i].expenditure;
					total.cash = Number(total.totalContrib) - Number(total.expenditure);

					totalGraphData.addItemAt(total, i);
				}

				for each(var item:Object in vo.list)
				{
					item.totalContrib = Number(item.check) + Number(item.credit) + Number(item.paypal);
				}
				incomeGraphData = vo.list;

				incomeGraphData.removeItemAt(0);
				totalGraphData.removeItemAt(0);

			}
		}

		private function generateSummaryResult(event:ResultEvent):void
		{
			dataLoading = false;

			if(event.result is ReportResultVO)
			{
				var vo:ReportResultVO = event.result as ReportResultVO;

				if(exporting)
				{
					exporting = false;
					Alert.show("There is nothing to export", "Error", 0, Application.application.root);
					return;
				}
				
				var newSummaryRecord:ArrayCollection = new ArrayCollection();

				// array index 0 is sum of all previous values
				// array index 1 is the values for the selected day only

				// today's summary
				vo.list[1].totalContrib = Number(vo.list[1].check) + Number(vo.list[1].credit) + Number(vo.list[1].paypal);

				vo.list[0].totalContrib = Number(vo.list[0].check) + Number(vo.list[0].credit) + Number(vo.list[0].paypal) + vo.list[1].totalContrib;
				vo.list[0].pledge = Number(vo.list[0].pledge) + Number(vo.list[1].pledge);
				vo.list[0].check = Number(vo.list[0].check) + Number(vo.list[1].check);
				vo.list[0].credit = Number(vo.list[0].credit) + Number(vo.list[1].credit);
				vo.list[0].paypal = Number(vo.list[0].paypal) + Number(vo.list[1].paypal);
				vo.list[0].cash = Number(vo.list[0].totalContrib) - Number(vo.list[1].expenditure);

				newSummaryRecord.addItem(vo.list[0]);
				newSummaryRecord.addItem(vo.list[1]);
				
				summaryRecord = newSummaryRecord;
			}
			else
			{
				var filename:String = exportTitle.replace(/\s/g,"_");
				var df:DateFormatter = new DateFormatter();
				df.formatString = "MM-DD-YYYY";
				navigateToURL(new URLRequest(gatewayBaseURL + '/export.php?id='+event.result+'&file_name='+filename+"_"+df.format(new Date())+'&refresh='+new Date().getTime()),'_parent')
				exporting = false;
			}
		}

		private function generateFault(event:FaultEvent):void
		{
			dataLoading = false;
			Alert.show("There was an error while trying to complete your request, please try again soon.", "Error", 0, Application.application.root, function():void {	return;	});
		}
					
		override public function newPage(event:Event):void
		{
			super.newPage(event);

			generate();
		}

		override public function sortRecords(event:DataGridEvent):void
		{
		 	// get the fieldname
		 	var fieldName:String;

			// sort by last name
	 		fieldName = event.dataField;

			if(fieldName == 'mod_group_name')
				fieldName = 'mod_group_id';

			if(fieldName == '_fid')
				fieldName = 'right(_fid,length(_fid)-length(\'FUND\'))';

			// If same field was selected, reverse the direction
		 	if(fieldName == sortArray[0].split(" ")[0])
		 	{
		 		if(sortArray[0].split(" ")[1] == 'DESC')
			 		sortArray[0] = fieldName +  ' ASC';
			 	else
			 		sortArray[0] = fieldName + ' DESC';
		 	}
		 	else
		 	// if not, order by the new field in ascending direction
		 	{
		 		sortArray[1] = sortArray[0];
			 	sortArray[0] = fieldName + ' ASC';
			}

		 	// loop through and highlight the sorted column
		 	for ( var i:int=0; i<event.target.columns.length; i++)
		 	{
		 		if(event.columnIndex == i)
		 			event.target.columns[i].setStyle('backgroundColor','#ededed');
		 		else
		 			event.target.columns[i].setStyle('backgroundColor','none');
		 	}
		 	
		 	generate();
		}

		public function inspectHandler(sid:String):void
		{
			new SidEvent(sid).dispatch();
		}

		public function chartDateClick(event:ChartItemEvent):void
		{
			summaryDate = EDateUtil.timestampToLocalDate(event.hitData.item.date);
			generateSummary();
		}

 		private function updateText():void
		{
			var plural:String = gridTotalRecords > 1 ? 's' : '';				
			
			if(gridTotalRecords < itemsPerPage)
			{
				recordsHtmlText = '<b>' + gridTotalRecords + '</b> record' + plural;
			}
			else
			{
				var startIndex:String = (gridCurrentPage * itemsPerPage + 1).toString();
				var toIndex:int =  gridCurrentPage * itemsPerPage + itemsPerPage;
				var toIndexString:String = toIndex < gridTotalRecords ? toIndex.toString() : gridTotalRecords.toString();
				
				recordsHtmlText = '<b>' + startIndex + '</b>';
				recordsHtmlText += '-<b>' + toIndexString + '</b>';
				recordsHtmlText += ' of <b>' + gridTotalRecords + '</b> record' + plural;				
			}
		}
		
		override public function exportGrid(columns:Array):void
		{
			super.exportGrid(columns);
			exportHeaders = [];
			exportFields = [];

			for each(var column:DataGridColumn in columns){
				exportHeaders.push(column.headerText);
				exportFields.push(column.dataField);
			}
			generate();
		}
	}
}