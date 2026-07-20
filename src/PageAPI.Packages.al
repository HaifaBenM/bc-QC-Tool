page 50100 "Talan QC Packages API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'package';
    EntitySetName = 'packages';
    SourceTable = "Config. Package";
    ODataKeyFields = Code;
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            field(code; Rec.Code)
            { Caption = 'code', Locked = true; }

            field(packageName; Rec."Package Name")
            { Caption = 'packageName', Locked = true; }


            field(numberOfErrors; Rec."No. of Errors")
            { Caption = 'numberOfErrors', Locked = true; }

            field(qcVisibleClient; Rec."Talan QC Visible")
            { Caption = 'qcVisibleClient', Locked = true; }
        }
    }
}