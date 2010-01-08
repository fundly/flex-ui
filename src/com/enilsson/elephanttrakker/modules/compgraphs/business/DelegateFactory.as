package com.enilsson.elephanttrakker.modules.compgraphs.business
{
	import mx.rpc.IResponder;
	
	public class DelegateFactory
	{
		public static const COMPGRAPH 		: String = "compgraph";
		public static const COMPGRAPH_MOCK	: String = "compgraph_mock";
		
		public static function create( type:String, services : Services ) : ICompGraphsDelegate {
			
			var d : ICompGraphsDelegate;
			
			switch( type ) {
				case COMPGRAPH:
					d = new CompGraphDelegate( services.comgraphService );
				break;
				case COMPGRAPH_MOCK:
					d = new CompGraphMockDelegate();
				break;
			}
			
			return d;
		}
	}
}