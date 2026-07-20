page 50106 "Talan QC Table Values API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'tableValue';
    EntitySetName = 'tableValues';
    SourceTable = "Talan QC Temp Value";
    SourceTableTemporary = true;
    ODataKeyFields = "Entry No.";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            field(entryNo; Rec."Entry No.")
            { Caption = 'entryNo', Locked = true; }
            field(tableId; Rec."Table ID")
            { Caption = 'tableId', Locked = true; }
            field(fieldNo; Rec."Field No.")
            { Caption = 'fieldNo', Locked = true; }
            field(code; Rec."Code Value")
            { Caption = 'code', Locked = true; }
        }
    }

    trigger OnOpenPage()
    var
        TableIdFilter: Integer;
        FieldNoFilter: Integer;
        FilterText: Text;
        RecRef: RecordRef;
        FldRef: FieldRef;
        KeyRef: KeyRef;
        EntryNo: Integer;
        CodeVal: Text;
    begin
        FilterText := Rec.GetFilter("Table ID");
        if FilterText = '' then exit;
        Evaluate(TableIdFilter, FilterText);
        if TableIdFilter = 0 then exit;

        FilterText := Rec.GetFilter("Field No.");
        if FilterText <> '' then
            Evaluate(FieldNoFilter, FilterText)
        else
            FieldNoFilter := 0;

        RecRef.Open(TableIdFilter);

        if FieldNoFilter = 0 then begin
            KeyRef := RecRef.KeyIndex(1);
            if KeyRef.FieldCount > 0 then
                FieldNoFilter := KeyRef.FieldIndex(1).Number;
        end;

        if FieldNoFilter = 0 then begin
            RecRef.Close();
            exit;
        end;

        EntryNo := 0;
        if RecRef.FindSet() then
            repeat
                FldRef := RecRef.Field(FieldNoFilter);
                CodeVal := Format(FldRef.Value);
                if CodeVal <> '' then begin
                    EntryNo += 1;
                    Rec.Init();
                    Rec."Entry No." := EntryNo;
                    Rec."Table ID" := TableIdFilter;
                    Rec."Field No." := FieldNoFilter;
                    Rec."Code Value" := CopyStr(CodeVal, 1, MaxStrLen(Rec."Code Value"));
                    Rec.Insert();
                end;
            until RecRef.Next() = 0;

        RecRef.Close();
    end;
}