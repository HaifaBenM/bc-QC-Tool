pageextension 50100 "Talan QC Package Card Ext" extends "Config. Package Card"
{
    layout
    {
        addafter("Package Name")
        {
            field("Talan QC Visible"; Rec."Talan QC Visible")
            {
                ApplicationArea = All;
                Caption = 'Visible QC Client';
                ToolTip = 'Cocher pour rendre ce package visible aux clients dans le Talan QC Tool.';
            }
        }
    }
}