package com.enilsson.elephantadmin.views.modules.batch.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.events.modules.batch.BatchEvent;
	import com.enilsson.elephantadmin.events.modules.batch.BatchListEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.events.BatchViewEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	[Bindable]
	public class BatchModel extends AbstractPM
	{
		//public static const 
		[Embed (source="/assets/images/admin_panel/magnifier_small.png")]
		public static const LIST_ICON:Class;

		[Embed (source="/assets/images/admin_panel/options_small.png")]
		public static const DETAIL_ICON:Class;

		public static const LIST_LABEL:String = "Batch List";

		public var batchListModel 	: BatchListModel;
		public var checkListModel 	: CheckListModel;
		public var batchDetailModel : BatchDetailModel;
		public var isBatchSelected	: Boolean;

		public function BatchModel( domainModel : EAModelLocator ) : void
		{
			super( domainModel );

			setUpListeners();
		}

		override public function set domainModel(domainModel:IModelLocator):void
		{
			_model = EAModelLocator( domainModel );
			super.domainModel = domainModel;
		}

		override protected function createChildren():void
		{
			batchListModel 		= new BatchListModel(_model);
			addChild(batchListModel);

			checkListModel 		= new CheckListModel(_model);
			addChild(checkListModel);

			batchDetailModel	= new BatchDetailModel(_model);
			addChild(batchDetailModel);
		}

		override public function set currentState(value : String):void
		{
			super.currentState = value;

			if(currentState == BatchState.ADD_BATCH)
			{
				new BatchEvent(BatchEvent.GET_CHECK_LIST).dispatch();
				batchListModel.batchList = new ArrayCollection();
			}
			else if(currentState == BatchState.VIEW_BATCH)
			{
				new BatchEvent(BatchEvent.GET_BATCH_LIST).dispatch();
				checkListModel.checkList = new ArrayCollection();
			}
		}

		public var playTransition:Boolean = false;
		public var rightPanelTitle:String;
		public var leftPanelTitle:String;
		public var centerPanelTitle:String;

		public function get itemsPerPage():int
		{
			return _model.itemsPerPage;
		}

		public function createNewBatch(event:BatchViewEvent = null):void
		{
			currentState = BatchState.ADD_BATCH
		}

		public function cancelNewBatch(event:BatchViewEvent = null):void
		{
			// Remove all checks from newBatchCheckList in the domain model
			new BatchListEvent(BatchListEvent.REMOVE_CHECKS_FROM_NEW_BATCH).dispatch();

			currentState = BatchState.VIEW_BATCH;
		}

		public function successCreateNewBatch(event:BatchViewEvent):void
		{
			batchDetailModel.isChanged = false;

			// Remove all checks from newBatchCheckList in the domain model
			new BatchListEvent(BatchListEvent.REMOVE_CHECKS_FROM_NEW_BATCH).dispatch();

			currentState = BatchState.VIEW_BATCH;
		}

		private function setUpListeners():void
		{
			batchListModel.addEventListener(BatchViewEvent.CREATE_NEW_BATCH, createNewBatch);
			batchDetailModel.addEventListener(BatchViewEvent.SUCCESS_CREATE_NEW_BATCH, successCreateNewBatch);
		}

		override public function firstShowHandler():void
		{
			super.firstShowHandler();
			currentState = BatchState.VIEW_BATCH;
		}

		override public function showHandler():void
		{
			super.showHandler();
			currentState = BatchState.VIEW_BATCH;
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator;
	}
}