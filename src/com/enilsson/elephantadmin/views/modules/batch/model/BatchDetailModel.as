package com.enilsson.elephantadmin.views.modules.batch.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.events.modules.batch.BatchEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.events.BatchViewEvent;
	import com.enilsson.elephantadmin.vo.ErrorVO;
	
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	[Bindable]
	public class BatchDetailModel extends AbstractPM
	{
		private static const NO_SELECTED_BATCH_TITLE:String = "You have no batches";
		private static const SELECTED_BATCH_TITLE:String = " Checks in Batch ";
		private static const NEW_BATCH_TITLE:String = "New Batch";
		private static const UPDATE_TITLE:String = "updateTitle";
		private static const NEW_BATCH_LIST_CHANGED:String = "newBatchListChanged";

		public var newBatchCheckList:ArrayCollection = new ArrayCollection();
		public var batchCheckList:ArrayCollection = new ArrayCollection();
		public var newBatchSaving:Boolean;
		public var isChanged:Boolean;
		public var isLoading:Boolean;

		public function BatchDetailModel( domainModel : EAModelLocator )
		{
			super( domainModel );
			currentState = BatchState.VIEW_BATCH;
		}

		override public function set domainModel(domainModel:IModelLocator):void
		{
			_model = EAModelLocator( domainModel );
			super.domainModel = domainModel;
		}

		override public function set currentState(value : String):void
		{
			super.currentState = value;
			dispatchEvent( new Event(UPDATE_TITLE) );
			if(currentState == BatchState.ADD_BATCH)
				batchCheckList = new ArrayCollection();
		}

		[Bindable(event="updateTitle")]
		public function get title():String
		{
			if (currentState == BatchState.VIEW_BATCH )
				if(_selectedBatch.id)
					return _selectedBatch.quantity + SELECTED_BATCH_TITLE + _selectedBatch.id;
				else
					return NO_SELECTED_BATCH_TITLE;
			else
				return NEW_BATCH_TITLE + " - " + newBatchCheckList.length + " items";
		}

		public function selectedBatchChanged(value:Object):void
		{
			_selectedBatch = value;
			isLoading = true;
			dispatchEvent( new Event(UPDATE_TITLE) );
		}
		private var _selectedBatch:Object;

		public function get itemsPerPage() : Number {
			return _model.itemsPerPage;
		}

		public function saveNewBatch():void
		{
			if(newBatchCheckList.length > 0)
			{
				var newBatchCheckIdList:Array = [];
				for each(var item:Object in newBatchCheckList)
				{
					newBatchCheckIdList.push(item.id);
				}
				new BatchEvent(BatchEvent.SAVE_BATCH, successCreateNewBatch).dispatch();
			} else {
				_model.errorVO = new ErrorVO( 
					'There are no checks to save', 
					'errorBox', 
					true 
				);
			}
		}

		public function successCreateNewBatch():void
		{
			// Notify parent view that new batch is successfully created
			dispatchEvent(new BatchViewEvent(BatchViewEvent.SUCCESS_CREATE_NEW_BATCH));
		}

		public function exportBatch():void
		{
			new BatchEvent(BatchEvent.EXPORT_BATCH).dispatch();
		}

		public function newBatchCheckListChanged( newBatchCheckList : ArrayCollection ) : void
		{
			this.newBatchCheckList = newBatchCheckList;
			if(newBatchCheckList.length > 0)
				isChanged = true;
			else
				isChanged = false;
			dispatchEvent( new Event(UPDATE_TITLE) );

		}

		public function batchCheckListChanged( batchCheckList : ArrayCollection ) : void
		{
			this.batchCheckList = batchCheckList;
			isLoading = false;
			dispatchEvent( new Event(UPDATE_TITLE) );
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter( newBatchCheckListChanged, _model, ["batch", "newBatchCheckList"] ), "newBatchCheckList" );
			addWatcher( BindingUtils.bindSetter( selectedBatchChanged, _model, ["batch", "selectedBatch"] ), "selectedBatch" );
			addWatcher( BindingUtils.bindSetter( batchCheckListChanged, _model, ["batch", "selectedBatchChecks"]), "selectedBatchChecks");
			addWatcher( BindingUtils.bindProperty(this, "newBatchSaving", _model, ["batch", "newBatchSaving" ] ), "newBatchSaving");
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator;
	}
}