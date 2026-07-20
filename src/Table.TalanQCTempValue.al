table 50101 "Talan QC Temp Value"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Table ID"; Integer) { Caption = 'Table ID'; }
        field(3; "Field No."; Integer) { Caption = 'Field No.'; }
        field(4; "Code Value"; Text[250]) { Caption = 'Code Value'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}