table 50105 "Talan QC Temp Table Caption"
{
    Caption = 'Talan QC Temp Table Caption';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(2; "Table Caption"; Text[250])
        {
            Caption = 'Table Caption';
        }
    }

    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }
}
