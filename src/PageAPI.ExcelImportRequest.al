
page 50390 "Talan QC Excel Import API"
{
    PageType = API;
    APIPublisher = 'talan';
    APIGroup = 'qctools';
    APIVersion = 'v1.0';
    EntityName = 'excelImportRequest';
    EntitySetName = 'excelImportRequests';
    SourceTable = "Talan QC Excel Import Req";
    DelayedInsert = true;
    Editable = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(packageCode; Rec."Package Code")
                {
                    Caption = 'Package Code';
                }
                field(fileContent; Rec."File Content")
                {
                    Caption = 'File Content';
                }
                field(success; Rec.Success)
                {
                    Caption = 'Success';
                }
                field(errorMessage; Rec."Error Message")
                {
                    Caption = 'Error Message';
                }
            }
        }
    }

    // AJOUTÉ (31/08/2026) — création "vide" : ne touche jamais au Blob ici,
    // évite tout conflit de flux au moment de l'insertion.
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Success := false;
        Rec."Error Message" := '';
        exit(true);
    end;

    // AJOUTÉ (31/08/2026) — c'est ICI, au moment du PATCH séparé qui
    // dépose fileContent sur un enregistrement déjà créé, que le
    // traitement réel se déclenche.
    trigger OnModifyRecord(): Boolean
    var
        ImportMgt: Codeunit "Talan QC Excel Import Mgt";
    begin
        ImportMgt.ProcessImport(Rec);
        exit(true);
    end;
}
