table 50103 "Talan QC Temp Record Value"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Table ID"; Integer) { Caption = 'Table ID'; }
        field(3; "Field No."; Integer) { Caption = 'Field No.'; }
        field(4; "Record Key"; Text[250]) { Caption = 'Record Key'; }
        field(5; "Value"; Text[250]) { Caption = 'Value'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
