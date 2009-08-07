package com.enilsson.elephantadmin.views.modules.batch.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.events.modules.batch.BatchEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.events.BatchViewEvent;
	import com.enilsson.events.PaginatorEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.events.ListEvent;
	
	[Bindable]
	public class BatchListModel extends AbstractPM
	{
		public var batchList:ArrayCollection;
		public function batchListUpdated(value:ArrayCollection):void
		{
			batchList = value;

			for each(var batch:Object in batchList)
			{
				if(batch.id == selectedBatchId)
				{
					selectedBatch = batch;
					// Workaround for refreshing the list in case selectedIndex remains the same after update
					batchListSelectedIndex = -1;
					// If the last selected batch id exists in the updated list, pre-select it
					batchListSelectedIndex = batchList.getItemIndex(batch);
					return;
				}
			}
			if(batchList.length > 0)
			{
				// If the last selected batch id doesn't exist in the updated list, select the top one
				// Also applies to the first time list is loaded
				batchListSelectedIndex = 0;
				var topBatch:Object = batchList.getItemAt(0);
				
				selectedBatch = topBatch;
			}
		}
		public var batchListTotal:int;
		public var batchListLoading:Boolean;
		public var batchListSelectedIndex:int;
		
		[Bindable(event="selectedBatchChanged")]
		public function get selectedBatch() : Object { return _selectedBatch; }
		public function set selectedBatch( value : Object ) : void 
		{
			if(value && value != _selectedBatch )
			{
				_selectedBatch = value;
				selectedBatchId = _selectedBatch.id;
				
				_model.batch.selectedBatch = _selectedBatch;
				
				new BatchEvent( BatchEvent.GET_CHECKS_FOR_BATCH ).dispatch();
				dispatchEvent(new Event("selectedBatchChanged"));
			}
		}
		private var _selectedBatch : Object;
		
		[Bindable(event="selectedBatchChanged")]
		public function get isBatchSelected() : Boolean { 
			return _selectedBatch != null;
		}
		
		public function set selectedBatchId( value : int ) : void { 
			_selectedBatchId = value;
			_model.batch.selectedBatchID = _selectedBatchId; 
		}
		public function get selectedBatchId() : int { return _selectedBatchId; }
		private var _selectedBatchId : int;
		
		

		public function BatchListModel( domainModel : EAModelLocator ):void
		{
			super( domainModel );
		}

		override public function set domainModel(domainModel:IModelLocator):void
		{
			_model = EAModelLocator( domainModel );
			super.domainModel = domainModel;
		}

		public function get itemsPerPage() : Number {
			return _model.itemsPerPage;
		}

		public function createNewBatchList():void
		{
			dispatchEvent(new BatchViewEvent(BatchViewEvent.CREATE_NEW_BATCH));
		}

		public function batchListChangeHandler(event:ListEvent):void
		{
			var batch : Object = event.itemRenderer.data;
			selectedBatch = batch;
		}
		
		public function getBatchList( event : PaginatorEvent = null ):void
		{
			if(event) {
				_model.batch.batchListFrom = event.index * itemsPerPage;
			} else {
				_model.batch.batchListFrom = 0;
			}
			new BatchEvent(BatchEvent.GET_BATCH_LIST).dispatch();
		}
		
		public function getOrderedBatches( orderField : String ) : void {
			_model.batch.batchListOrderField = orderField;
			getBatchList();
		}
		
		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(batchListUpdated, _model, ["batch", "batchList" ] ), "batchList");
			addWatcher( BindingUtils.bindProperty(this, "batchListTotal", _model, ["batch", "batchListTotal" ] ), "batchListTotal");
			addWatcher( BindingUtils.bindProperty(this, "batchListLoading", _model, ["batch", "batchListLoading" ] ), "batchListLoading");
			addWatcher( BindingUtils.bindProperty(this, "selectedBatchId", _model, ["batch", "selectedBatchID" ] ), "selectedBatchID");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator;
	}
}