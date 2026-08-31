// AJOUTÉ (27/08/2026) — voir Tab50109.TalanQCExcelImportReq.al pour le
// contexte complet. Un POST sur cette page (JSON avec packageCode et
// fileContent en base64) déclenche OnInsertRecord, qui appelle le
// codeunit d'import (voir Cod50109.TalanQCExcelImportMgt.al).
//
// Exemple d'appel côté Python (bc_api.py) :
//   POST .../api/talan/qctools/v1.0/companies({id})/excelImportRequests
//   { "packageCode": "MDD-PAYS", "fileContent": "<base64 du xlsx>" }
// Réponse : la même entité, avec "success" et "errorMessage" renseignés.
page 50109 "Talan QC Excel Import API"
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ImportMgt: Codeunit "Talan QC Excel Import Mgt";
    begin
        ImportMgt.ProcessImport(Rec);
        exit(true);
    end;
}
