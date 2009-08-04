package com.enilsson.elephantadmin.models.viewclasses
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class BatchViewClass
	{
		// List of previous batches
		public var batchList:ArrayCollection = new ArrayCollection();
		public var batchListTotal:int;
		public var batchListFrom:int;
		public var batchListLoading:Boolean;
		public var batchListOrderField : String;
		public var batchListOrder : String;

		// selected batch to be displayed in the details view
		public var selectedBatch:Object = {};
		public var selectedBatchID:int = -1;
		// the checks belonging to the selected batch
		public var selectedBatchChecks : ArrayCollection = new ArrayCollection();
		public var selectedBatchChecksFrom:int;
		public var selectedBatchChecksTotal:int;
		public var selectedBatchChecksLoading : Boolean;
		public var selectedBatchChecksOrderField : String;
		public var selectedBatchChecksOrder : String;
		

		// List of unfulfilled pledges
		public var pledgeList:ArrayCollection = new ArrayCollection();
		public var pledgeListTotal:int;
		public var pledgeListFrom:int;
		public var pledgeListLoading:Boolean;

		// List of all unfulfilled check contributions that are not already assigned to a batch
		public var checkList:ArrayCollection = new ArrayCollection();
		public var checkListTotal:int;
		public var checkListFrom:int;
		public var checkListLoading:Boolean;
		public var checkListOrderField : String;
		public var checkListOrder : String;
		public var checkListSearchOption : Object;

		// List of checks that will go into a new batch
		public var newBatchCheckList : ArrayCollection = new ArrayCollection();
		public var newBatchSaving : Boolean;
	}
}