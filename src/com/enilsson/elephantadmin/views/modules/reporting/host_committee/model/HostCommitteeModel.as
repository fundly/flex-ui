package com.enilsson.elephantadmin.views.modules.reporting.host_committee.model
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportModuleModel;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportResultVO;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.elephantadmin.views.modules.reporting.host_committee.events.ExportEvent;
	import com.enilsson.utils.EDateUtil;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.Application;
	import mx.events.DataGridEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.ListEvent;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	[Bindable]
	public class HostCommitteeModel extends ReportModuleModel
	{
		public var eventFilter:ArrayCollection = new ArrayCollection();
		public var eventID:int;
		public var hostFilter:ArrayCollection = new ArrayCollection([
			{'label':'All Pledges'}
		]);
		public var hostID:int;

		public var gridTotal:ArrayCollection;
		public var pledgeRecords:ArrayCollection;
		public var recordsHtmlText:String;
		public var eventSelectedIndex:int = -1;
		public var viewstack:int;

		private var sortArray:Array = ['fundraising_goal DESC'];
		private var pledgeSortArray:Array = ['pledge_date DESC'];
		private var exportHeaders:Array = [];
		private var exportFields:Array = [];
		private var exportTitle:String = "";
		
		public var pledgeTotalRecords:int;
		public var pledgeCurrentPage:int;

		public var chart:EventChartModel;
		
		public var showSharedCredit : Boolean;

		public function HostCommitteeModel():void
		{
		}

		override public function init():void
		{
			super.init();
			getEventList();
			chart = new EventChartModel(gatewayURL);

		}

		public function viewstackChangeHandler(event:IndexChangedEvent):void
		{
			viewstack = event.newIndex;
			if(eventID != 0)
				generate();
		}

		public function eventChangeHandler(event:ListEvent):void
		{
			if(! event.currentTarget.selectedItem) return;
			
			eventID = event.currentTarget.selectedItem.id;
			eventSelectedIndex = event.currentTarget.selectedIndex;
			hostID = 0;
			viewstack = 0;
			generate();
		}

		public function changeHost( item : Object ):void
		{
			if(!item) return;
			pledgeCurrentPage = 0;
			hostID = item.data;
			getHostPledges();
		}
		
		public function getEventList():void
		{
			dataLoading = true;	
			
 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.' + instanceID + '.reporting.host_committee';
			amfService.addEventListener(ResultEvent.RESULT, getEventListResult);
			amfService.addEventListener(FaultEvent.FAULT, getEventListFault); 
			amfService['get_event_list'].send.apply(null);
		}

		private function getEventListResult(event:ResultEvent):void
		{
			dataLoading = false;
			eventFilter = ReportResultVO(event.result).list;
			
			for each(var item:Object in eventFilter)
			{
				item['label'] = item['source_code'] + " - " + item['name'];
			}
			
			sortByName(eventFilter,"label");
			if(recordID != 0)
			{
				for(var i:int = 0; i < eventFilter.length; i++)
				{
					if(eventFilter.getItemAt(i).id == recordID)
					{
						eventSelectedIndex = i;
						break;
					}
				}
				eventID = recordID;
				generate();
				recordID = 0;
			}

		}

		private function getEventListFault(event:FaultEvent):void
		{
			dataLoading = false;
		}
	
		override public function generate():void
		{
			super.generate();
			if(viewstack == 0)
				getHosts();
			else
				getHostPledges();
		}

		public function getHosts():void
		{
			dataLoading = true;	
			hostFilter = new ArrayCollection([{'label':'Loading Hosts'}]);

			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");

			vo.sortBy = sortBy;
			vo.eventID = eventID;
			vo.page = gridCurrentPage;
			vo.recordPerPage = itemsPerPage;
			vo.groupID = group;
			vo.showSharedCredit = showSharedCredit;

			if(exporting)
			{
				var cf:CurrencyFormatter = new CurrencyFormatter();
				cf.currencySymbol = "$";
				cf.precision = 2;
				cf.useNegativeSign = false;
				exportTitle = 'Event Host Committee Report, Event: ' + eventFilter.getItemAt(eventSelectedIndex).label + 
				', Goal: ' + cf.format(eventFilter.getItemAt(eventSelectedIndex).fundraising_goal)
				+', Total Event Pledged:' + cf.format(eventFilter.getItemAt(eventSelectedIndex).pledge_total)+', Total Event Contributed:' + cf.format(eventFilter.getItemAt(eventSelectedIndex).contrib_total);

				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				vo.exportTitle = exportTitle;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
				vo.exportTimeOffset = timezoneOffset;
				vo.exportData = [eventFilter.getItemAt(eventSelectedIndex).name,
					eventFilter.getItemAt(eventSelectedIndex).source_code,
					eventFilter.getItemAt(eventSelectedIndex).fundraising_goal,
					eventFilter.getItemAt(eventSelectedIndex).pledge_total,
					eventFilter.getItemAt(eventSelectedIndex).contrib_total,
					eventFilter.getItemAt(eventSelectedIndex).date_time
					]
			}

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.' + instanceID + '.reporting.host_committee';
			amfService['get_host_committee'].send.apply(null, [vo]);	
			amfService.addEventListener(ResultEvent.RESULT, getHostsResult);
			amfService.addEventListener(FaultEvent.FAULT, getHostsFault);
		}

		private function getHostsResult(event:ResultEvent):void
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
				
				gridRecords = vo.list;
				gridTotalRecords = vo.total_records;
				updateText();
				hostFilter = new ArrayCollection([{'label':'All Pledges','data':0}]);
				var totalPledged:int = 0;
				var totalContrib:int = 0;
				var totalGoal:int = 0;
				var totalOutstanding:int = 0;

				for each(var item:Object in gridRecords)
				{
					var name:String = item.fname + " " + item.lname;
					hostFilter.addItem({ 'label' : name, 'data' : item.user_id });

					totalPledged += int(item.pledge_total);
					totalContrib += int(item.contrib_total);
					totalGoal += int(item.fundraising_goal);
					totalOutstanding += int(item.outstanding);
				}
				sortByName(hostFilter,"data");

				gridTotal = new ArrayCollection([{
					'fname':'Total',
					'pledge_total':totalPledged,
					'contrib_total':totalContrib,
					'fundraising_goal':totalGoal,
					'outstanding':totalOutstanding
				}]);
			
				chart.getChartData(eventID);
			}
			else
			{
				var filename:String;
				filename = 'Event_Host_Committee';
				var df:DateFormatter = new DateFormatter();
				df.formatString = "MM-DD-YYYY";
				navigateToURL(new URLRequest(gatewayBaseURL + '/export.php?id='+event.result+'&file_name='+filename+"_"+df.format(new Date())+'&refresh='+new Date().getTime()),'_parent')
				exporting = false;
			}
		}

		private function getHostsFault(event:FaultEvent):void
		{
			dataLoading = false;	
			Alert.show("There was an error while trying to complete your request, please try again soon.", "Error", 0, Application.application.root, function():void {	return;	});
		}

		public function getHostPledges():void
		{
			dataLoading = true;	
			
			var vo:ReportVO = new ReportVO();
			var sortBy:String = pledgeSortArray.join(",");

			vo.sortBy = sortBy;
			vo.filter = -1;
			vo.eventID = eventID;
			vo.userID = hostID;
			vo.page = pledgeCurrentPage;
			vo.recordPerPage = itemsPerPage;
			vo.showSharedCredit = showSharedCredit;

			if(exporting)
			{
				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				vo.exportTitle = 'Pledges for Event: ' + eventFilter.getItemAt(eventSelectedIndex).label;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
				vo.exportTimeOffset = timezoneOffset;
			}

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.' + instanceID + '.reporting.all_pledges';
			amfService['get_all_pledges'].send.apply(null, [vo]);	
			amfService.addEventListener(ResultEvent.RESULT, getHostPledgesResult);
			amfService.addEventListener(FaultEvent.FAULT, getHostPledgesFault); 
		}

		private function getHostPledgesResult(event:ResultEvent):void
		{
			dataLoading = false;	
			if(event.result is ReportResultVO)
			{
				if(exporting)
				{
					exporting = false;
					Alert.show("There is nothing to export", "Error", 0, Application.application.root);
				}

				var vo:ReportResultVO = event.result as ReportResultVO;
				pledgeRecords = vo.list;
				pledgeTotalRecords = vo.total_records;
				updateText();
			}
			else
			{
				var filename:String;
				filename = 'Event_Pledges_Report';
				var df:DateFormatter = new DateFormatter();
				df.formatString = "MM-DD-YYYY";
				navigateToURL(new URLRequest(gatewayBaseURL + '/export.php?id='+event.result+'&file_name='+filename+"_"+df.format(new Date())+'&refresh='+new Date().getTime()),'_parent')
				exporting = false;
			} 

		}

		private function getHostPledgesFault(event:FaultEvent):void
		{
			dataLoading = false;	
			Alert.show("There was an error while trying to complete your request, please try again soon.", "Error", 0, Application.application.root, function():void {	return;	});
		}
					
		override public function newPage(event:Event):void
		{
			pledgeCurrentPage = event.currentTarget.selectedPage;
			getHostPledges();
		}

		override public function sortRecords(event:DataGridEvent):void
		{
		 	// get the fieldname
		 	var fieldName:String;

			// sort by last name
	 		fieldName = event.dataField;
			if(fieldName == 'status')
				fieldName = '(pledges.pledge_amount - pledges.contrib_total)';

			if(fieldName == 'mod_group_name')
				fieldName = 'mod_group_id';

			// If same field was selected, reverse the direction
		 	if(fieldName == pledgeSortArray[0].split(" ")[0])
		 	{
		 		if(pledgeSortArray[0].split(" ")[1] == 'DESC')
			 		pledgeSortArray[0] = fieldName +  ' ASC';
			 	else
			 		pledgeSortArray[0] = fieldName + ' DESC';
		 	}
		 	else
		 	// if not, order by the new field in ascending direction
		 	{
			 	pledgeSortArray[0] = fieldName + ' ASC';
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

 		private function updateText():void
		{
			var plural:String;
			if(viewstack == 0)
			{
				plural = gridTotalRecords > 1 ? 's' : '';				
				
				recordsHtmlText = '<b>' + gridTotalRecords + '</b> record' + plural;
			}
			else
			{
				plural = pledgeTotalRecords > 1 ? 's' : '';				
				
				if(pledgeTotalRecords < itemsPerPage)
				{
					recordsHtmlText = '<b>' + pledgeTotalRecords + '</b> record' + plural;
				}
				else
				{
					var startIndex:String = (gridCurrentPage * itemsPerPage + 1).toString();
					var toIndex:int =  gridCurrentPage * itemsPerPage + itemsPerPage;
					var toIndexString:String = toIndex < pledgeTotalRecords ? toIndex.toString() : pledgeTotalRecords.toString();
					
					recordsHtmlText = '<b>' + startIndex + '</b>';
					recordsHtmlText += '-<b>' + toIndexString + '</b>';
					recordsHtmlText += ' of <b>' + pledgeTotalRecords + '</b> record' + plural;				
				}

			}
		}
		
		override public function exportGrid(columns:Array):void
		{
			super.exportGrid(columns);
			exportHeaders = [];
			exportFields = [];

			for each(var column:DataGridColumn in columns)
			{
				exportHeaders.push(column.headerText);
				exportFields.push(column.dataField);
			}
			generate();
		}
		
		private function sortByName(arrCol:ArrayCollection, name:String):void
		{
			var dataSortField:SortField = new SortField();
			dataSortField.name = name;
			dataSortField.caseInsensitive = true;
			
			var stringDataSort:Sort = new Sort();
			stringDataSort.fields = [dataSortField];
			
			arrCol.sort = stringDataSort;
			arrCol.refresh();
		}

		public function setExportGrid(columns:Array):void
		{
			exportHeaders = [];
			exportFields = [];

			for each(var column:DataGridColumn in columns)
			{
				exportHeaders.push(column.headerText);
				exportFields.push(column.dataField);
			}
		}

		public function exportMultiple(event:ExportEvent):void
		{
			dataLoading = true;
			var vos:Array = [];
			
			var cf:CurrencyFormatter = new CurrencyFormatter();
			cf.currencySymbol = "$";
			cf.precision = 2;
			cf.useNegativeSign = false;

			for each(var id:int in event.ids)
			{
				var vo:ReportVO = new ReportVO();

				var sortBy:String = sortArray.join(",");
	
				vo.sortBy = sortBy;
				vo.filter = -1;
				vo.eventID = id;
				vo.userID = hostID;

				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				vo.showSharedCredit = showSharedCredit;

				var selectedEvent:Object;
				for each(var e:Object in eventFilter)
				{
					if(e.id == id)
					{
						selectedEvent = e;
						break
					}
				}
				vo.exportTitle = selectedEvent.name;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
				vo.exportTimeOffset = timezoneOffset;
				var df:DateFormatter = new DateFormatter();
				df.formatString = "MM/DD/YYYY";

				vo.exportData = {
					"name":selectedEvent.name,
					"source_code":selectedEvent.source_code,
					"fundraising_goal":selectedEvent.fundraising_goal,
					"pledge_total":selectedEvent.pledge_total,
					"contrib_total":selectedEvent.contrib_total,
					"outstanding":(Number(selectedEvent.fundraising_goal) - Number(selectedEvent.contrib_total) ),
					"date_time":df.format(EDateUtil.timestampToLocalDate(selectedEvent.date_time))
				};
				vos.push(vo);
			}

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.' + instanceID + '.reporting.host_committee';
			amfService.addEventListener(ResultEvent.RESULT, exportMultipleResult);
			amfService.addEventListener(FaultEvent.FAULT, exportMultipleFault);
			
			amfService['export_multiple'].send.apply(null, [vos]);
		}

		private function exportMultipleResult(event:ResultEvent):void
		{
			var filename:String = 'Host_Committee_Reports_';
			var df:DateFormatter = new DateFormatter();
			df.formatString = "MM-DD-YYYY";
			navigateToURL(new URLRequest(gatewayBaseURL + '/export.php?id='+event.result+'&ext=xls&file_name='+filename+df.format(new Date())+'&refresh='+new Date().getTime()),'_parent')
			dataLoading = false;
		}

		private function exportMultipleFault(event:FaultEvent):void
		{
			Alert.show("There was an error while trying to complete your request, please try again soon.", "Error", 0, Application.application.root, function():void {	return;	});
			dataLoading = false;
		}
	}
}