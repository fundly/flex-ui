package com.enilsson.elephantadmin.commands.modules.batch
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.business.modules.BatchDelegate;
	import com.enilsson.elephantadmin.events.modules.batch.BatchEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.renderers.CheckWrapper;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class BatchCommand extends SequenceCommand implements ICommand
	{
		private var mainModel:EAModelLocator = EAModelLocator.getInstance();
		private var callBack:Function;

		override public function execute(event:CairngormEvent):void
		{
			var batchEvent:BatchEvent = BatchEvent(event);
			callBack = batchEvent.callBack;
			
			switch(batchEvent.type)
			{
				case BatchEvent.GET_BATCH_LIST:
					getBatches(); 
				break;
				case BatchEvent.GET_CHECK_LIST:
					getChecks(); 
				break;
				case BatchEvent.GET_PLEDGE_LIST:
					getPledges(); 
				break;
				case BatchEvent.SAVE_BATCH:
					saveBatch(); 
				break;
				case BatchEvent.EXPORT_BATCH :
					exportBatch();
				break;
				case BatchEvent.GET_CHECKS_FOR_BATCH :
					getChecksForBatch();
				break;
			}
		}

		/**
		 * Get list of batches
		 */
		private function getBatches():void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getBatches, onFault_getBatches);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			mainModel.dataLoading = true;
			mainModel.batch.batchListLoading = true;
			
			if(!mainModel.batch.batchListOrderField)
				mainModel.batch.batchListOrderField = 'id';
			if(!mainModel.batch.batchListOrder)
				mainModel.batch.batchListOrder = 'DESC';

			var recordsVO:RecordsVO = new RecordsVO(
				"checks_batches<quantity:amount:created_on>(created_by_id<lname:fname:_fid>)"
				, null
				, "checks_batches." + mainModel.batch.batchListOrderField + " " + mainModel.batch.batchListOrder
				, mainModel.batch.batchListFrom
				, mainModel.itemsPerPage
				, "P"
			);
			delegate.getRecords( recordsVO );
		}

		private function onResults_getBatches(event:ResultEvent):void 
		{
			if(mainModel.debug) Logger.info('getBatches Success', ObjectUtil.toString(event.result));
			
			mainModel.dataLoading = false;
			mainModel.batch.batchListLoading = false;

			mainModel.batch.batchListTotal = event.result.total_rows;

			var tableName:String = event.result.table_name;

			var batchList:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result[tableName])
			{
				batchList.addItem(item);
			}
			mainModel.batch.batchList = batchList;
		}

		private function onFault_getBatches(event:FaultEvent):void
		{
			if(mainModel.debug) Logger.info('getBatches Fail', ObjectUtil.toString(event));
			
			mainModel.dataLoading = false;
			mainModel.batch.batchListLoading = false;
		}
		
		
		/**
		 * Get list of checks for a selected batch
		 */
		private function getChecksForBatch():void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResult_getChecksForBatch, onFault_getChecksForBatch);
// 			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			var delegate:BatchDelegate = new BatchDelegate(handlers)
			
			mainModel.dataLoading = true;
			mainModel.batch.selectedBatchChecksLoading = true;
			
			if(!mainModel.batch.selectedBatchChecksOrderField)
				mainModel.batch.selectedBatchChecksOrderField = 'id';
			if(!mainModel.batch.selectedBatchChecksOrder)
				mainModel.batch.selectedBatchChecksOrder = 'DESC';
			
/* 			var recordsVO:RecordsVO = new RecordsVO(
				"checks<amount:full_name:entry_date>(pledge_id<fname:lname:pledge_date:pledge_amount:address1:address2:city:state:zip:occupation:employer>(user_id<fname:lname:_fid>))"
				, 	{
						statement: '(1)',
						'1' : {
								what: "checks.batch_id",
								op: "=",
								val: mainModel.batch.selectedBatchID
							}
					}
				, "checks." + mainModel.batch.selectedBatchChecksOrderField + " " + mainModel.batch.selectedBatchChecksOrder
			);
			delegate.getRecords( recordsVO );
 */			var order:String = "checks." + mainModel.batch.selectedBatchChecksOrderField + " " + mainModel.batch.selectedBatchChecksOrder;
			delegate.getBatchChecks(mainModel.batch.selectedBatchID, order, 0, 1000, "P");
		}
		
		private function onResult_getChecksForBatch( event : ResultEvent ) : void
		{
			if(mainModel.debug) Logger.info('getChecksForBatch Success', ObjectUtil.toString(event.result));
			
			mainModel.dataLoading = false;
			mainModel.batch.selectedBatchChecksLoading = false;

			mainModel.batch.selectedBatchChecksTotal = event.result.total_rows;

			var tableName:String = event.result.table_name;

			var checkList:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result[tableName])
			{
				checkList.addItem(item);
			}
			mainModel.batch.selectedBatchChecks = checkList;	
		}
		private function onFault_getChecksForBatch( event : FaultEvent ) : void
		{
			if(mainModel.debug) Logger.info('getChecksForBatch Fail', ObjectUtil.toString(event));
			
			mainModel.dataLoading = false;
			mainModel.batch.selectedBatchChecksLoading = false;
		}
		
		
		
		/**
		 * Get list of unfulfilled check contributions
		 */			
		private function getChecks():void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getChecks, onFault_getChecks);
			var delegate:BatchDelegate = new BatchDelegate(handlers);

			mainModel.dataLoading = true;
			mainModel.batch.checkListLoading = true;
		
			var whereObj:Object =
				{
					statement : "(1) AND (2)" 
				,	1 :	{	what : "checks.entry_date"
						,	val : "0"
						,	op : "="
						}
				,	2 :	{	what : "checks.batch_id"
						,	val : "NULL"
						,	op : "IS"
						}
				};
			
			var option : Object = mainModel.batch.checkListSearchOption;
			if(option) 
			{
				// default: option.type == exact
				var value : String = option.value;
				var operator : String = '=';
				
				if(option.type == 'any') {
					value = '%'+value+'%';
					operator = 'LIKE';
				}
				
				whereObj.statement = "(1) AND (2) AND (3)";
				whereObj['3'] = {
					what: option.column,
					val: value,
					op: operator
				};
			}
			var orderField : String = mainModel.batch.checkListOrderField ? mainModel.batch.checkListOrderField : "checks.amount";
			var listOrder : String = mainModel.batch.checkListOrder ? mainModel.batch.checkListOrder : "DESC";
			var order : String = orderField + " " + listOrder;

/*  			var recordsVO:RecordsVO = new RecordsVO(
				"checks<amount:full_name:entry_date>(pledge_id<fname:lname:pledge_date:pledge_amount:address1:address2:city:state:zip:occupation:employer>(user_id<fname:lname:_fid>))"
				, whereObj
				, order
				, mainModel.batch.checkListFrom
				, mainModel.itemsPerPage
				, "P"
			);
 */ 			
			delegate.getAllUnfulfilledChecks(whereObj, order, mainModel.batch.checkListFrom, mainModel.itemsPerPage, "P");
		}

		private function onResults_getChecks(event:ResultEvent):void
		{
			if(mainModel.debug) Logger.info('getChecks Success', ObjectUtil.toString(event.result));
			
			mainModel.dataLoading = false;
			mainModel.batch.checkListLoading = false;

			mainModel.batch.checkListTotal = event.result.total_rows;

			var tableName:String = event.result.table_name;

			var checkList:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result[tableName])
			{
				var wrapper : CheckWrapper = new CheckWrapper( item );
				
				// If check is already added to the new batch list, flag it with isInBatch
				for each(var existingItem:Object in mainModel.batch.newBatchCheckList)
				{
					if(existingItem.id == item.id) {
						wrapper.inBatch = true;
						break;
					}
				}
				
				checkList.addItem(wrapper);
			}
			mainModel.batch.checkList = checkList;
		}

		private function onFault_getChecks(event:FaultEvent):void
		{
			if(mainModel.debug) Logger.info('getChecks Fail', ObjectUtil.toString(event));
			
			mainModel.dataLoading = false;
			mainModel.batch.checkListLoading = false;
		}

		/**
		 * Get list of unfulfilled pledges
		 */			
		private function getPledges():void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_getPledges, onFault_getPledges);
			var delegate:RecordsDelegate = new RecordsDelegate(handlers);
			
			mainModel.dataLoading = true;

			var whereObj:Object =
				{
					statement:	"(1)"
				,	1 :	{	what : "pledges.contrib_total"
						,	val : "pledges.pledge_amount"
						,	op : "<"
						}
				};
			var recordsVO:RecordsVO = new RecordsVO("pledges"
				, whereObj
				, "pledges.created_on DESC"
				, mainModel.batch.pledgeListFrom
				, mainModel.itemsPerPage
				, "P"
			);
			delegate.getRecords( recordsVO );
		}

		private function onResults_getPledges(event:ResultEvent):void 
		{
			if(mainModel.debug) Logger.info('getRecords Success', ObjectUtil.toString(event.result));
			
			mainModel.dataLoading = false;

			mainModel.batch.pledgeListTotal = event.result.total_rows;

			var tableName:String = event.result.table_name;

			var pledgeList:ArrayCollection = new ArrayCollection();
			for each( var item:Object in event.result[tableName])
			{
				pledgeList.addItem(item);
			}
			mainModel.batch.pledgeList = pledgeList;
		}

		private function onFault_getPledges(event:FaultEvent):void
		{
			if(mainModel.debug) Logger.info('get PledgesRecords Fail', ObjectUtil.toString(event));
			
			mainModel.dataLoading = false;
		}

		/**
		 * Save a new batch 
		 */			
		private function saveBatch():void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_saveBatch, onFault_saveBatch);
			var delegate:BatchDelegate = new BatchDelegate(handlers);

			mainModel.dataLoading = true;
			mainModel.batch.newBatchSaving = true;

			var checkIDs:Array = [];
			// create an array of selected checks to send
			for each(var check:Object in mainModel.batch.newBatchCheckList )
			{
				checkIDs.push( check.id );
			}
			delegate.saveNewBatch( checkIDs );
		}

		private function onResults_saveBatch(event:ResultEvent):void 
		{
			if(mainModel.debug) Logger.info('Batch Module saveBatch Result', ObjectUtil.toString(event.result));
			
			//model.formProcessing = false;
			mainModel.dataLoading = false;
			mainModel.batch.newBatchSaving = false;

			switch(event.result.state)
			{
				case true :
					mainModel.errorVO = new ErrorVO('New batch saved successfully!', 'successBox', true );
					// save the inserted id to the model so it will be pre-selected it when it returns to list state
					var insertedID:int =  event.result.details;
					mainModel.batch.selectedBatchID = insertedID;
					// call back to PM telling it to change to list state and refresh the batch list
					callBack();
				break;
				default :
					var newList:ArrayCollection = new ArrayCollection( mainModel.batch.newBatchCheckList.toArray() );

					for each(var error:Object in event.result.errors)
					{
					
/* 					for each(var check:Object in mainModel.batch.newBatchCheckList)
					{
							check.max_limit = true;
							newList.addItem(check);
					}
 */
						for each(var check:Object in newList)
						{
							if(error.check_id == check.id)
								check.errorString = error.errorString;
						}
					}

					mainModel.errorVO = new ErrorVO( 
						'There was a problem processing this record:<br><br>- One of more checks exceed the maximum donation limit.', 
						'errorBox', 
						true 
					);

					mainModel.batch.newBatchCheckList = newList;
				break;
			}
		}
		
		private function onFault_saveBatch(event:FaultEvent):void
		{
			if(mainModel.debug) Logger.info('Batch Module saveBatch Fail', ObjectUtil.toString(event));
			
			mainModel.dataLoading = false;
			mainModel.batch.newBatchSaving = false;
		}

		/**
		 * Save a new batch 
		 */			
		private function exportBatch():void
		{
			var handlers:IResponder = new mx.rpc.Responder(onResults_exportBatch, onFault_exportBatch);
			var delegate:BatchDelegate = new BatchDelegate(handlers);
			
			mainModel.dataLoading = true;
			mainModel.batch.batchListLoading = true;

			delegate.exportBatch(mainModel.batch.selectedBatchID);
/* 			var whereObj:Object =
				{
					statement:	"(1)"
				,	1 :	{	what : "checks.batch_id"
						,	val : mainModel.batch.selectedBatchID
						,	op : "="
						}
				};
			var recordsVO:RecordsVO = new RecordsVO(
				"checks<amount:full_name:entry_date>(pledge_id<pledge_date:fname:lname:address1:address2:city:state:zip:occupation:employer>(user_id<fname:lname:_fid>))"
				, whereObj
				, "checks.amount DESC"
				, 0
				, 1000000
				, "X"
			);

			delegate.getRecords( recordsVO );
 */		}

		private function onResults_exportBatch(event:ResultEvent):void 
		{
			if(mainModel.debug) Logger.info('Batch Module exportBatch Result', ObjectUtil.toString(event.result));
			
			mainModel.batch.batchListLoading = false;
			mainModel.dataLoading = false;

			if(event.result > 0)
			{
				var df:DateFormatter = new DateFormatter();
				df.formatString = "MM-DD-YYYY";

				navigateToURL(
					new URLRequest(
						mainModel.gatewayBaseURL + '/export.php?id='+event.result
						+ "&refresh=" + new Date().getTime() 
						+ "&file_name=Batch_" + mainModel.batch.selectedBatchID + "_" + df.format(new Date())
					),'_parent');
			} else {
				var eMsg:String = '';
				for(var i:String in event.result.errors)
					eMsg += '- ' + event.result.errors[i] + '<br>';
					
				mainModel.errorVO = new ErrorVO( 
					'There was a problem exporting batch:<br><br>' + eMsg, 
					'errorBox', 
					true 
				);
			}
		}
		
		private function onFault_exportBatch(event:FaultEvent):void
		{
			if(mainModel.debug) Logger.info('Batch Module exportBatch Fail', ObjectUtil.toString(event));

			mainModel.batch.batchListLoading = false;
			mainModel.dataLoading = false;
		}
	}
}