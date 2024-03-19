/*

---------------------------------------------------------
Create a Custom action that sets Order Block Contingent ID
---------------------------------------------------------

Description:

-- This query creates a custom action view that allows the end user of the view to add contingent ids to blocks
-- the contingent ids are generated via sequences
-- To see the results:
    1. Go to the order blotter, 
    2. Select the Set_contingent_order_id action
    3. Select some order blocks
    4. Click run
    5. See contingent id be set with a dynamically generated value from sequences

More details:

    https://support.lusid.com/knowledgebase/article/KA-01767/en-us

*/



@@providerName = select 'Set_contingent_order_id';
@data = values
  ('blockUpdateExample', "ORD-BLKTEST-BLK1");
@block_ids = select
  column1 as scope,
  column2 as code
FROM @data;

--- Create the view
@view = use Sys.Admin.SetupView with @@providerName, @block_ids
--provider={@@providerName}
--description="An example process that can be triggered for a set of Blocks"
--parameters
BlockIds,Table,@block_ids,true,Block scopes+codes
----

@block_ids = select * from #PARAMETERVALUE(BlockIds);

-- Trigger sequence and get contingent id

@sequence = SELECT 1 as NextBatch, 
'order_block_contingent_id_cycling' as Code, 
'Next' as WriteAction,
'blockUpdateExample' as Scope;
@contingent_id = select NextValueInSequence as Contingent_Id, WriteErrorCode, WriteError from Lusid.Sequence.Writer where toWrite = @sequence;

@@contingent_id_string = SELECT Contingent_Id from @contingent_id LIMIT 1;

-- Add contingent Ids to the target blocks
@blocks = SELECT
@@contingent_id_string as Contingent_Id,
b.* 
FROM @block_ids bi
INNER JOIN Lusid.Block b
ON bi.scope = b.BlockScope AND
bi.code = b.BlockCode;

-- Write updated values to the block
@inserpt = select * from Lusid.Block.Writer where toWrite = @blocks;

@@result = SELECT
CASE
    WHEN WriteErrorCode = 0 THEN 'Contingent IDS written as ' || Contingent_Id
    ELSE 'There was an issue with your Contingent ID. Error: ' || WriteError
END AS result
FROM @contingent_id LIMIT 1;

select @@result as result;


enduse;
@created = select * from @view;

--- Set the requirement metadata on the view
@metadata = values
  (@@providerName, 'OrderBlotterBlockAction', 'True');
@toWrite = select
  column1 as ProviderName,
  column2 as MetadataKey,
  column3 as MetadataValue
from @metadata;
select * from Sys.Registration.Metadata.Writer
  where ToWrite = @toWrite