page 50101 "Talan QC Package Tables API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'packageTable';
    EntitySetName = 'packageTables';
    SourceTable = "Config. Package Table";
    ODataKeyFields = "Package Code", "Table ID";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            field(packageCode; Rec."Package Code")
            { Caption = 'packageCode', Locked = true; }

            field(tableId; Rec."Table ID")
            { Caption = 'tableId', Locked = true; }

            field(tableName; Rec."Table Name")
            { Caption = 'tableName', Locked = true; }

            field(processingOrder; Rec."Processing Order")
            { Caption = 'processingOrder', Locked = true; }

            field(skipTableTriggers; Rec."Skip Table Triggers")
            { Caption = 'skipTableTriggers', Locked = true; }

            field(deleteBeforeProcessing; Rec."Delete Recs Before Processing")
            { Caption = 'deleteBeforeProcessing', Locked = true; }
            field(tableEnglishName; GetTableEnglishName())
            { Caption = 'tableEnglishName', Locked = true; }


        }
    }
    local procedure GetTableEnglishName(): Text
    var
        RecRef: RecordRef;
    begin
        if Rec."Table ID" = 0 then exit('');
        RecRef.Open(Rec."Table ID");
        exit(RecRef.Name);
    end;
}