tableextension 50100 "Talan QC Config Package" extends "Config. Package"
{
    fields
    {
        field(50100; "Talan QC Visible"; Boolean)
        {
            Caption = 'Visible QC Client', Locked = true;
            DataClassification = CustomerContent;
        }
    }
}