package com.enilsson.elephantadmin.views.modules.reporting.donationwidget.model
{
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportModuleModel;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportResultVO;
	import com.enilsson.elephantadmin.views.modules.reporting.base.ReportVO;
	import com.enilsson.utils.EDateUtil;
	
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
	public class DonationWidgetModel extends ReportModuleModel
	{
		private const ONE_DAY:int = 24 * 60 * 60;
		private const WIDGET_USER_ID:int = -100;

		public var currentState : String = "basic";
		public var paymentMethodData : ArrayCollection;

		// default start date is start of today
		public var startDate:int = EDateUtil.todayToTimestamp() - ONE_DAY;
		// default end date is end of today
		public var endDate:int = EDateUtil.todayToTimestamp();
		public var sortArray:Array = ['pledge_date DESC'];
		public var exportHeaders:Array = [];
		public var exportFields:Array = [];
		public var exportTitle:String = "";
		public var totalPledgeSum:Number = 0;
		public var totalContribSum:Number = 0;
		public var recordsHtmlText:String;
		private var service:RemoteObject;
		private var contrib_service:RemoteObject;

		public var cumulativePaymentsData : ArrayCollection;
		public var typeFilter:ArrayCollection = new ArrayCollection([
			{label:'All',data:'4'}
			,{label:'Credit Card',data:'1'}
			,{label:'PayPal',data:'3'}
		]);

		public var recentPaymentsData : ArrayCollection = new ArrayCollection();
		
		public var pledgeDetailsData : ArrayCollection = new ArrayCollection();

		public function setService(service:RemoteObject, contrib_service:RemoteObject):void
		{
			this.service = service;
			this.contrib_service = contrib_service;
		}

		public function refresh():void
		{
			if(currentState == 'basic')
			{
				service.total_contributions();
				service.cumulative_payments();
				service.latest_payments();
			} else {
				generate();
			}
		}

		public function typeChangeHandler(event:Event):void
		{
			if(event.currentTarget.selectedItem)
				filter = event.currentTarget.selectedItem.data;
		}

		public function handleTotalContributionsResult( event : ResultEvent ) : void
		{
			paymentMethodData = new ArrayCollection([
				{ paymentMethod : 'Credit Card', count : Number(event.result.total_transactions) },
				{ paymentMethod : 'PayPal', count : Number(event.result.total_paypal) }
			]);
		}
		
		public function handleCumulativePaymentsResult( event : ResultEvent ) : void
		{
			cumulativePaymentsData = event.result.list;
		}
		
		public function handleLatestPaymentsResult( event : ResultEvent ) : void
		{
			recentPaymentsData = event.result.list;
		}
		

		public function handleFault( event : FaultEvent ) : void
		{
			var e : FaultEvent = event;
		}

		override public function generate():void
		{
			super.generate();

			// if no vo was passed through, get parameters from the UI
			var vo:ReportVO = new ReportVO();
			var sortBy:String = sortArray.join(",");
			vo.startTime = startDate;
			vo.endTime = endDate + ONE_DAY;
			vo.sortBy = sortBy;
			vo.filter = filter;
			vo.page = gridCurrentPage;
			vo.recordPerPage = itemsPerPage;
			vo.groupID = group;
			vo.userID = WIDGET_USER_ID;
			vo.exportData = { userID_type :"recorded_by_id"}

			if(exporting)
			{
				vo.export = true;
				vo.exportHeaders = exportHeaders;
				vo.exportFields = exportFields;
				if(filter == 0)
					exportTitle = 'Widget Pledges';
				else if(filter == 1)
					exportTitle = 'Widget Pledges - Credit Card';
				else if(filter == 2)
					exportTitle = 'Widget Pledges - PayPal';
				vo.exportTitle = exportTitle;
				vo.page = 0;
				vo.recordPerPage = 10000000000;
				vo.exportTimeOffset = timezoneOffset;
			}

			Logger.info('SEND',ObjectUtil.toString(vo));

			contrib_service.get_all_contributions_fulfilled(vo);
		}

		public function generateResult(event:ResultEvent):void
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
				if(vo.addData)
				{
					if(vo.addData['pledge_total'])
						totalPledgeSum = vo.addData['pledge_total'];
					else
						totalPledgeSum = 0;

					if(vo.addData['contrib_total'])
						totalContribSum = vo.addData['contrib_total'];
					else
						totalContribSum = 0;
				} else {
					totalPledgeSum = 0;
				}
				updateText();
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
			Logger.info('RETURN',ObjectUtil.toString(event.fault))
			Alert.show("Internet connection error please try again soon (" + event.fault + ")", "Error", 0, Application.application.root, function():void {	return;	});
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
			if(fieldName == 'status')
				fieldName = '(pledges.pledge_amount - pledges.contrib_total)';

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