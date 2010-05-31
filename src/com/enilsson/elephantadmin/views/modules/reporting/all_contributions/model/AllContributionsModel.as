package com.enilsson.elephantadmin.views.modules.reporting.all_contributions.model
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportModuleModel;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportResultVO;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.utils.EDateUtil;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
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
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	[Bindable]
	public class AllContributionsModel extends ReportModuleModel
	{
		private const FILTER_ALL:uint = 0;
		private const FILTER_CREDIT_CARD:uint = 1;
		private const FILTER_CHECK:uint = 2;
		private const FILTER_PAYPAL:uint = 3;

		private const FILTER_PLEDGE_DATE:uint = 0;
		private const FILTER_FULFILLED_DATE:uint = 1;

		public var contributionFilter:ArrayCollection = new ArrayCollection([
			{'label':'All','data':FILTER_ALL},
			{'label':'Credit Card','data':FILTER_CREDIT_CARD},
			{'label':'Check','data':FILTER_CHECK},
			{'label':'PayPal','data':FILTER_PAYPAL}
		]);
		public var regionFilter:ArrayCollection = new ArrayCollection([
			{'label':'All','data':'0'}
		]);
		public var dateTypeFilter:ArrayCollection = new ArrayCollection([
			{'label':'Fulfilled Date','data':FILTER_FULFILLED_DATE},
			{'label':'Pledge Date','data':FILTER_PLEDGE_DATE}
		]);

		public var dateType:int = FILTER_FULFILLED_DATE;
		// default start date is start of today
		public var startDate:Date = EDateUtil.today();
		// default end date is end of today
		public var endDate:Date = EDateUtil.today();
		
		// flag indicating if refunds should be shown or not
		public var showRefunds : Boolean;
		
		// flag indicating if shared credit contributions should be shown or not
		public var showSharedCredit : Boolean;

		public var sortArray:Array = ['pledge_date DESC'];
		public var exportHeaders:Array;
		public var exportFields:Array;
		public var exportTitle:String
		public var totalContribSum:Number = 0;

		public var recordsHtmlText:String;
		
		private var _dateFormatter : DateFormatter = new DateFormatter();
		
		public function AllContributionsModel():void
		{
			
		}

		override public function init():void
		{
			super.init();
			for each(var item:Object in userGroups)
			{
				regionFilter.addItem(item);
			}
			generateFirstPage();
		}

		public function statusChangeHandler(event:ListEvent):void
		{
			filter = event.currentTarget.selectedItem.data;
		}

		public function dateTypeChangeHandler(event:ListEvent):void
		{
			dateType = event.currentTarget.selectedItem.data;
		}

		public function regionChangeHandler(event:ListEvent):void
		{
			gridCurrentPage = 0;
			group = event.currentTarget.selectedItem.value;
		}

		override public function generate():void
		{
			super.generate();
			
			// if no vo was passed through, get parameters from the UI
			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");
			
			EDateUtil.setEndOfDay(endDate);

			vo.startTime = EDateUtil.localDateToTimestamp(startDate);
			vo.endTime = EDateUtil.localDateToTimestamp(endDate);
			
			vo.sortBy = sortBy;
			vo.filter = filter;
			vo.page = gridCurrentPage;
			vo.recordPerPage = itemsPerPage;
			vo.groupID = group;
			vo.showRefunds = showRefunds;
			vo.showSharedCredit = showSharedCredit;

			if(exporting)
			{
				if(filter == FILTER_ALL)
					exportTitle = 'All Contributions';
				else if(filter == FILTER_CREDIT_CARD)
					exportTitle = 'Credit Card Contributions';
				else if(filter == FILTER_CHECK)
					exportTitle = 'Check Contributions';
				else if(filter == FILTER_PAYPAL)
					exportTitle = 'PayPal Contributions';

				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				vo.exportTimeOffset = timezoneOffset;
				vo.exportTitle = exportTitle;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
			}

			Logger.info('SEND',ObjectUtil.toString(vo));

 			var amfService:RemoteObject = new RemoteObject('amfphp');
			amfService.endpoint = gatewayURL;
			amfService.source = 'plugins.' + instanceID + '.reporting.all_contributions';
			if( dateType == FILTER_PLEDGE_DATE )
				amfService['get_all_contributions'].send.apply(null, [vo]);
			else if(dateType == FILTER_FULFILLED_DATE )
				amfService['get_all_contributions_fulfilled'].send.apply(null, [vo]);
			amfService.addEventListener(ResultEvent.RESULT, generateResult);
			amfService.addEventListener(FaultEvent.FAULT, generateFault); 
		}

		private function generateResult(event:ResultEvent):void
		{
			dataLoading = false;	

			Logger.info('RETURN',ObjectUtil.toString(event.result));

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
				if(gridTotalRecords > 0 && vo.addData)
				{
					switch(filter)
					{
						case FILTER_ALL:
							if(vo.addData['contrib_total'])
								totalContribSum = vo.addData['contrib_total'];
							break;

						case FILTER_CREDIT_CARD:
							if(vo.addData['credit_total'])
								totalContribSum = vo.addData['credit_total'];
							break;

						case FILTER_CHECK:
							if(vo.addData['check_total'])
								totalContribSum = vo.addData['check_total'];
							break;

						case FILTER_PAYPAL:
							if(vo.addData['paypal_total'])
								totalContribSum = vo.addData['paypal_total'];
							break;
					}
				}
				else {
					totalContribSum = 0;
				}
				updateText();
			}
			else 
			{
				var filename:String;
				filename = exportTitle.replace(/\s/g,"_");
				_dateFormatter.formatString = "MM-DD-YYYY";
				navigateToURL(new URLRequest(gatewayBaseURL + '/export.php?id='+event.result+'&file_name='+filename+"_"+_dateFormatter.format(new Date())+'&refresh='+new Date().getTime()),'_parent')
				exporting = false;
			}
		}

		private function generateFault(event:FaultEvent):void
		{
			dataLoading = false;	
			Logger.info('RETURN',ObjectUtil.toString(event.fault))
			Alert.show("There was an error while trying to complete your request, please try again soon.", "Error", 0, Application.application.root, function():void {	return;	});
		}

		override public function newPage(event:Event):void
		{
			super.newPage(event);

			generate();
		}

		override public function sortRecords(event:DataGridEvent):void
		{
		 	var fieldName:String;

			// sort by last name
	 		fieldName = event.dataField;

			if(fieldName == 'mod_group_name')
				fieldName = 'mod_group_id';

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